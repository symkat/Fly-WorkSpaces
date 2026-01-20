package Fly::WorkSpace;
use Mojo::Base 'Mojolicious', -signatures;
use Fly::WorkSpace::DB;

# This method will run once at server start
sub startup ($self) {

    # Load configuration from config file
    my $config = $self->plugin('NotYAMLConfig');

    if ( $ENV{WORKSPACE_DATABASE} ) {
        $self->config->{database}->{workspace} = $ENV{WORKSPACE_DATABASE};
    }

    if ( $ENV{MINION_DATABASE} ) {
        $self->config->{database}->{minion} = $ENV{MINION_DATABASE};
    }

    # Configure the application
    $self->secrets($config->{secrets});

    # Set the session cookie expires to 30 days.
    $self->sessions->default_expiration(2592000);


    # Add Fly::WorkSpaces::Command to the commands search path.
    push @{$self->commands->namespaces}, 'Fly::WorkSpace::Command';


    # Create $self->db as a WorkSpace::DB connection.
    $self->helper( db => sub {
        Fly::WorkSpace::DB->connect($self->config->{database}->{workspace});
    });

    # Helper to redirect on errors, support setting the form and errors in a flash
    # if they exist in the stash.
    $self->helper( redirect_error => sub ( $c, $redirect_to, $redirect_args = {}, $errors = [] ) {
        push @{$c->stash->{errors}}, @{$errors}    if $errors;
        $c->flash( form   => $c->stash->{form}   ) if $c->stash->{form};
        $c->flash( errors => $c->stash->{errors} ) if $c->stash->{errors};

        $c->redirect_to( $c->url_for( $redirect_to, $redirect_args ) );
    });



    # Router
    my $router = $self->routes;

    # Load credentials for authenticated users, but still allow unauthenticated users.
    my $r = $router->under( '/' => sub ($c) {

        # Login via session cookie.
        if ( $c->session('uid') ) {
            my $person = $c->db->person( $c->session('uid') );

            if ( $person && $person->is_enabled ) {
                $c->stash->{person} = $person;
                return 1;
            }
        }

        return 1;
    });


    # Authenticated router - A user account is required.
    my $auth = $r->under( '/' => sub ($c) {

        # Make sure a logged in user exists.
        return 1 if $c->stash->{person};

        # No user account for this seession, redirect the user to the login page.
        $c->redirect_to( $c->url_for( 'show_login' ) );
        return undef;
    });

    # Admin router - A user account is required and that account must be marked as an admin.
    my $admin = $auth->under( '/' => sub ($c) {

        return 1 if $c->stash->{person}->is_admin;

        # No admin account for this seession, redirect the user to the dashboard.
        $c->redirect_to( $c->url_for( 'show_dashboard' ) );
        return undef;
    });


    # Normal route to controller
    $r->get    ('/'                     )->to('Root#index'              )->name( 'show_homepage' );

    # User login, and logout.
    $r->get   ( '/login'                )->to( 'Auth#login'             )->name('show_login' );
    $r->post  ( '/login'                )->to( 'Auth#do_login'          )->name('do_login'   );
    $auth->get( '/logout'               )->to( 'Auth#do_logout'         )->name('do_logout'  );
    
    # Dashboard
    $auth->get ('/dashboard'               )->to('Dashboard#index'         )->name( 'show_dashboard'        );
    $auth->post('/dashboard'               )->to('Dashboard#do_create'     )->name( 'create_workspace'      );
    $auth->get ('/dashboard/destroy/:name' )->to('Dashboard#destroy'       )->name( 'show_destroy_workspace');
    $auth->post('/dashboard/destroy'       )->to('Dashboard#do_destroy'    )->name( 'destroy_workspace'     );
    $auth->post('/dashboard/kick'          )->to('Dashboard#do_kick'       )->name( 'kick_workspace'        );

    my $minion_auth = $admin->under( '/minion' => sub ($c) { return 1; } );

    # Minion and helpers plugin (down here because we need the router done).
    $self->plugin( 'Fly::WorkSpace::Plugin::MinionTasks', { route => $minion_auth } );
}

1;
