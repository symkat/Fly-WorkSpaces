package Fly::WorkSpace::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Try::Tiny;
use DateTime;


#==
# GET /login | show_login | templates/auth/login.html.ep
#
# If a user is already logged in, redirect them to the dashboard instead
# of showing the login page.
#==
sub login ( $c ) {
    if ( $c->stash->{person} ) {
        $c->redirect_to( $c->url_for( 'show_dashboard' ) );
    }
}

#==
# POST /login | do_login
#       email     - The email address of the account to login to.
#       password  - The password for the account to login to.
#
# Try to login to the account owned by the email address with the
# supplied password.
#
# If the account exists and password matches, set the session uid
# to the user's account id.  This will load the correct account to
# $c->stash->{person} on the next page load.
#
# Show the login page with error messages when there has been an error.
#
# Redirect the user to the dashboard on successful login.
#==
sub do_login ( $c ) {
    my $email    = $c->stash->{form}->{email}    = $c->param('email');
    my $password = $c->stash->{form}->{password} = $c->param('password');

    # Did we get an email address and a password?
    push @{$c->stash->{errors}}, "You must supply an email address to login."
        unless $email;

    push @{$c->stash->{errors}}, "You must suply a password to login."
        unless $password;

    return $c->redirect_error( 'show_login' )
        if $c->stash->{errors};

    # Can we load a user account?
    my $person = $c->db->resultset('Person')->find( { email => $email } )
        or push @{$c->stash->{errors}}, "Invalid email address or password.";

    return $c->redirect_error( 'show_login' )
        if $c->stash->{errors};

    # Does the user account we loaded have a password that matches the one supplied?
    $person->auth_password->check_password( $password )
        or push @{$c->stash->{errors}}, "Invalid email address or password.";

    return $c->redirect_error( 'show_login' )
        if $c->stash->{errors};

    # Everything is good, log the user in and send them to the dashboard.
    $c->session->{uid} = $person->id;
    $c->redirect_to( $c->url_for( 'show_dashboard' ) );
}

#==
# POST /logout | do_logout
#
# Log a user out of their account.
#
# If an admin has logged into a user's account through the admin_become interface,
# then logging out will return the admin to their account instead of logging them
# out completely.
#==
sub do_logout ( $c ) {

    # When an admin has impersonated a user, they'll have their uid
    # stored to oid.  When they logout, they are logging out of the
    # impersonated user's account, back into their own account.
    # If a url is set in the session, the admin is returned to that page.
    if ( $c->session->{oid} ) {
        $c->session->{uid} = delete $c->session->{oid};
        if ( $c->session->{url} ) {
            $c->redirect_to( $c->url_for( delete $c->session->{url} ) );
        } else {
            $c->redirect_to( $c->url_for( 'show_admin' ) );
        }
        return;
    }

    # Delete the session cookie and return them to the homepage.
    undef $c->session->{uid};
    $c->redirect_to( $c->url_for( 'show_homepage' ) );
}


1;
