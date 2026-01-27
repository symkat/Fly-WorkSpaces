package WebService::Sprites;
use Moo;
#use URI::Encode qw( uri_encode );
use LWP::UserAgent;
use JSON::MaybeXS qw( encode_json decode_json );
use URI;
use Data::Dumper;

our $VERSION = '0.002';

has base_url => (
    is       => 'rw',
    required => 1,
);

has api_key => (
    is       => 'rw',
    required => 1,
);

has ua => (
    is      => 'ro',
    lazy    => 1,
    builder => sub { 
        return LWP::UserAgent->new( timeout => 300, headers => [ 'Accept-Encoding' => '', 'Authorization' => 'Bearer ' . shift->api_key ]); 
    },
);

has mech => (
    is      => 'ro',
    lazy    => 1,
    builder => sub { 
        my $mech = WWW::Mechanize->new( timeout => 300 );
        $mech->add_header( 'Accept-Encoding' => '' );
        return $mech;
    },
);

sub create_sprite {
    my ( $self, @in ) = @_;
    
    my $args = ref $in[0] eq 'HASH' ? $in[0] : { @in };

    my $req = HTTP::Request->new( POST => $self->base_url. "/v1/sprites" );
       $req->content_type( 'application/json');
       $req->header( Authorization => 'Bearer ' . $self->api_key );
       $req->content( encode_json( { name => $args->{name}, url_settings => { auth => $args->{url_settings} } } ));

    my $res = $self->ua->request( $req );


    #$VAR1 = '{"id":"sprite-5a16465b-84d0-41d7-b648-2178c6a879cb","name":"my-new-sprite","status":"cold","url":"https://my-new-sprite-4ral.sprites.app","updated_at":"2026-01-13T23:22:20.958444Z","created_at":"2026-01-13T23:22:20.958444Z","organization":"kate-17","url_settings":{"auth":"public"}}';


    return decode_json($res->decoded_content);
}

sub destroy_sprite {
    my ( $self, @in ) = @_;
    
    my $args = ref $in[0] eq 'HASH' ? $in[0] : { @in };
    
    my $req = HTTP::Request->new( DELETE => $self->base_url. "/v1/sprites/" . $args->{name} );
       $req->content_type( 'application/json');
       $req->header( Authorization => 'Bearer ' . $self->api_key );

    my $res = $self->ua->request( $req );

    return $res;
}

sub sprite_exec {
    my ( $self, @in ) = @_;
    
    my $args = ref $in[0] eq 'HASH' ? $in[0] : { @in };

    my $saved_timeout = $self->ua->timeout;
    $self->ua->timeout( $args->{timeout} )
        if exists $args->{timeout};
    
    my $url = URI->new( $self->base_url. "/v1/sprites/" . $args->{name} . "/exec" );
       $url->query_form(
            cmd => $args->{cmd},
            ( exists $args->{path} ? ( path => $args->{path} )  : () ),
            ( exists $args->{env}  ? ( env  => $args->{env}  )  : () ),
            ( exists $args->{dir}  ? ( dir  => $args->{dir}  )  : () ),
       );
    my $req = HTTP::Request->new( POST => $url );
       $req->content_type( 'application/json');
       $req->header( Authorization => 'Bearer ' . $self->api_key );

    my $res = $self->ua->request( $req );

    $self->ua->timeout( $saved_timeout )
        if $args->{timeout};
    
    return $res;
    
    #return decode_json($res->decoded_content);
}

sub create_screenshot_url {
    my ( $self, @in ) = @_;

    my $args = ref $in[0] eq 'HASH' ? $in[0] : { @in };

    die "Error: create_screenshot_url() requires a url argument.\n" unless 
        $args->{url};

    die "Error: create_screenshot_url() must be http(s)\n"
        unless URI->new($args->{url})->scheme =~ /^https?$/;

    return sprintf( "%s/api/screenshot?resX=%d&resY=%d&outFormat=%s&waitTime=%d&isFullPage=%s&url=%s",
        $self->base_url,
        exists $args->{res_x}         ? $args->{res_x}         : $self->res_x,
        exists $args->{res_y}         ? $args->{res_y}         : $self->res_y,
        exists $args->{out_format}    ? $args->{out_format}    : $self->out_format,
        exists $args->{wait_time}     ? $args->{wait_time}     : $self->wait_time,
        exists $args->{is_full_page}  ? $args->{is_full_page}  : $self->is_full_page,
        uri_encode($args->{url})
    );
}

sub fetch_screenshot {
    my ( $self, @in ) = @_;

    my $args = ref $in[0] eq 'HASH' ? $in[0] : { @in };
    
    my $res = $self->ua->get( $self->create_screenshot_url( $args ) );
    
    if ( $res->content_type eq 'application/json' ) {
        die "Error: " . decode_json($res->decoded_content)->{details};
    } 

    return $res;
}

1;
