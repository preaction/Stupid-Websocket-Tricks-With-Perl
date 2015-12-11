
use Mojolicious::Lite;
use Mojo::IOLoop;
use Mojo::IOLoop::Stream;

websocket '/' => sub {
    my ( $c ) = @_;
    my ( $stream );

    $c->on( message => sub {
        my ( $c, $msg ) = @_;

        if ( $stream ) {
            $stream->close;
            undef $stream;
        }

        $c->app->log->info( "Got command: $msg" );

        if ( my $pid = open my $fh, '-|', $msg ) {
            $stream = Mojo::IOLoop::Stream->new( $fh );

            $stream->on( read => sub {
                my ( $stream, $bytes ) = @_;
                $c->app->log->debug( "Sending output: $bytes" );
                $c->send( $bytes );
            } );
            $stream->on( close => sub {
                kill KILL => $pid;
                close $fh;
            } );

            my $sid = Mojo::IOLoop->stream( $stream );
            $c->on(finish => sub { Mojo::IOLoop->remove($sid) });
        }
        else {
            $c->send( "Could not execute '$msg': $!" );
        }
    } );
};

app->start;
