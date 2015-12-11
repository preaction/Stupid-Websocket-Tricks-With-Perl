
# Client-side

---

# Connect to WebSocket

```javascript
ws = new WebSocket( 'ws://localhost:7000/' );
```

---

# Send the command

```javascript
ws.onopen = function () {
    var cmd = $( '#command' ).val();
    ws.send( cmd );
};
```

---

# Handle output

```javascript
ws.onmessage = function ( msg ) {
    $( '#output' ).append( msg.data );
    // Scroll to the bottom of the output panel
    $( '#output' ).scrollTop( $( '#output' ).prop('scrollHeight') );
};
```

------

# Server-side

---

# Build WebSocket route
```perl
websocket '/' => sub {
    my ( $c ) = @_;

    $c->on( message => sub { ... } );
};
```

---

# Run the command
```perl
my ( $c, $msg ) = @_;

my $pid = open my $fh, '-|', $msg;
```

---

# Wrap in Mojo Stream
```perl
my $stream = Mojo::IOLoop::Stream->new( $fh );
```

---

# Stream to WebSocket
```perl
$stream->on( read => sub {
    my ( $stream, $bytes ) = @_;
    $c->app->log->debug( "Sending output: $bytes" );
    $c->send( $bytes );
} );
```

---

# Clean up
```perl
$stream->on( close => sub {
    kill KILL => $pid;
    close $fh;
} );
```

---

# Add to IOLoop
```perl
my $sid = Mojo::IOLoop->stream( $stream );
$c->on( finish => sub {
    Mojo::IOLoop->remove( $sid );
} );
```

------

# Mercury

---

# WebSocket Message Patterns

---

# Live Demo!

<http://preaction.me:5000>
