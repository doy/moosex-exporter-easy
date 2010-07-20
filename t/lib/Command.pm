package Command;
use MooseX::Exporter::Easy;

class_metaroles {
    class => ['Command::Role::Class'],
};

sub _command_method_meta {
    my ($meta) = @_;
    Moose::Meta::Class->create_anon_class(
        superclasses => [$meta->method_metaclass],
        roles        => ['Command::Role::Method'],
        cache        => 1,
    )->name;
}

with_meta command => sub {
    my ($meta, $name, $code) = @_;
    $meta->add_method(
        $name => _command_method_meta($meta)->wrap(
            $code,
            name                 => $name,
            package_name         => $meta->name,
            associated_metaclass => $meta
        ),
    );
};

export;

1;
