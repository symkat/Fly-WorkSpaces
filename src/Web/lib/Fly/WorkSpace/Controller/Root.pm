package Fly::WorkSpace::Controller::Root;
use Mojo::Base 'Mojolicious::Controller', -signatures;


sub index ($c) {
    # Send a logged in user to the dashboard.
    $c->redirect_to( $c->url_for( 'show_dashboard') )
        if exists $c->stash->{person};

    # Send everyone else to the login page
    $c->redirect_to( $c->url_for( 'show_login' ) );
}

1;
