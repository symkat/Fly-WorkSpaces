package Fly::WorkSpace::Controller::Dashboard;
use Mojo::Base 'Mojolicious::Controller', -signatures;

# This action will render a template
sub welcome ($self) {

  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to the Mojolicious real-time web framework!');
}


# This action will render a template
sub index ($self) {

  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to the Mojolicious real-time web framework!');
}

sub destroy ($c) {
    $c->stash->{sprite} = $c->stash->{person}->search_related('sprites', {name => $c->param('name')})->first;

}

sub do_create ($c) {

    my $name = $c->stash->{form_name} = $c->param('name');
    my $desc = $c->stash->{form_desc} = $c->param('desc');

    #push @{$c->stash->{errors}}, "Email is required." unless $email;
    #push @{$c->stash->{errors}}, "Password is required." unless $pass;

    $c->minion->enqueue( create_workspace => [ $c->stash->{person}->id, $name, $desc ]);

    $c->flash( confirmation => 'Your workspace is being created -- please refresh in a minute.' );

    $c->redirect_to( 'show_dashboard' );
}

sub do_destroy ($c) {
    my $name = $c->stash->{form_name} = $c->param('name');

    my $record = $c->stash->{person}->search_related('sprites', { name => $name })->first;

    if ( ! $record ) {
        push @{$c->stash->{errors}}, "You don't have permission to that workspace.";
        return 1;
    }


    $c->minion->enqueue( destroy_workspace => [ $name ]);
    $record->delete;

    $c->flash( confirmation => 'Your workspace has been deleted.  You meant to, right?' );

    $c->redirect_to( 'show_dashboard' );
}

sub do_kick ($c) {
    my $name = $c->stash->{form_name} = $c->param('name');

    my $record = $c->stash->{person}->search_related('sprites', { name => $name })->first;

    if ( ! $record ) {
        push @{$c->stash->{errors}}, "You don't have permission to that workspace.";
        return 1;
    }

    $c->minion->enqueue( start_workspace => [ $name ]);

    $c->flash( confirmation => 'Your workspace was kicked, give it another go!' );

    $c->redirect_to( 'show_dashboard' );
}

1;
