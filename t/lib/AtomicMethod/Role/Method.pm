package AtomicMethod::Role::Method;
use Moose::Role;

around wrap => sub {
    my ($orig, $self, $body, @args) = @_;
    my $new_body = sub {
        warn "locking...\n";
        my @ret = $body->(@_); # XXX: context
        warn "unlocking...\n";
        return @ret;
    };
    $self->$orig($new_body, @args);
};

1;
