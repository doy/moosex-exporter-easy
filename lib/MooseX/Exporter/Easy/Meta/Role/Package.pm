package MooseX::Exporter::Easy::Meta::Role::Package;
use Moose::Role;

has with_meta => (
    traits  => ['Array'],
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
    handles => {
        with_meta      => 'elements',
        _add_with_meta => 'push',
    }
);

sub add_with_meta {
    my $self = shift;
    my ($name, $sub) = @_;
    $self->add_package_symbol('&' . $name, $sub);
    $self->_add_with_meta($name);
}

has as_is => (
    traits  => ['Array'],
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
    handles => {
        as_is      => 'elements',
        _add_as_is => 'push',
    }
);

sub add_as_is {
    my $self = shift;
    my ($name, $sub) = @_;
    $self->add_package_symbol('&' . $name, $sub);
    $self->_add_as_is($name);
}

has also => (
    traits => ['Array'],
    isa    => 'ArrayRef[Str]',
    default => sub { [] },
    handles => {
        also     => 'elements',
        add_also => 'push',
    }
);

has class_metaroles => (
    is        => 'rw',
    isa       => 'HashRef[ArrayRef[Str]]',
    predicate => 'has_class_metaroles',
);

has role_metaroles => (
    is        => 'rw',
    isa       => 'HashRef[ArrayRef[Str]]',
    predicate => 'has_role_metaroles',
);

has base_class_roles => (
    traits => ['Array'],
    isa    => 'ArrayRef[Str]',
    default => sub { [] },
    handles => {
        base_class_roles     => 'elements',
        add_base_class_roles => 'push',
        has_base_class_roles => 'count',
    }
);

sub setup_exporter {
    my $self = shift;;

    my ($import, $unimport, $init_meta) = Moose::Exporter->build_import_methods(
        exporting_package => $self->name,
        with_meta         => [$self->with_meta],
        as_is             => [$self->as_is],
        also              => [$self->also],
        $self->has_class_metaroles
            ? (class_metaroles => $self->class_metaroles)
            : (),
        $self->has_role_metaroles
            ? (role_metaroles => $self->role_metaroles)
            : (),
        $self->has_base_class_roles
            ? (base_class_roles => [$self->base_class_roles])
            : (),
    );

    $self->add_package_symbol('&import' =>
        ($self->has_package_symbol('&import_extra')
            ? sub {
                  my ($package, @args) = @_;
                  $package->import_extra(@args);
                  goto $import;
              }
            : $import)
    );
    $self->add_package_symbol('&unimport' =>
        ($self->has_package_symbol('&unimport_extra')
            ? sub {
                  my ($package, @args) = @_;
                  $package->unimport_extra(@args);
                  goto $unimport;
              }
            : $unimport)
    );
    if ($init_meta) {
        $self->add_package_symbol('&init_meta' =>
            ($self->has_package_symbol('&init_meta_extra')
                ? sub {
                    my ($package, @args) = @_;
                    $package->init_meta_extra(@args);
                    goto $init_meta;
                }
                : $init_meta)
        );
    }
    elsif ($self->has_package_symbol('&init_meta_extra')) {
        $self->add_package_symbol('&init_meta' =>
            sub { goto $_[0]->can('init_meta_extra') }
        );
    }
}

no Moose::Role;

1;
