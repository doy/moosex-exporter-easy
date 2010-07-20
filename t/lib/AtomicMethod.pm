package AtomicMethod;
use MooseX::Exporter::Easy;

sub _atomic_method_meta {
    my ($meta) = @_;
    Moose::Meta::Class->create_anon_class(
        superclasses => [$meta->method_metaclass],
        roles        => ['AtomicMethod::Role::Method'],
        cache        => 1,
    )->name;
}

with_meta atomic_method => sub {
    my ($meta, $name, $code) = @_;
    $meta->add_method(
        $name => _atomic_method_meta($meta)->wrap(
            $code,
            name                 => $name,
            package_name         => $meta->name,
            associated_metaclass => $meta
        ),
    );
};

export;

1;
