package MooseX::Exporter::Easy;
use Moose ();
use Moose::Exporter;

use Carp qw(confess);
use Scalar::Util qw(blessed);

Moose::Exporter->setup_import_methods(
    with_meta => [qw(with_meta as_is also
                     class_metaroles role_metaroles base_class_roles
                     export)],
);

sub with_meta {
    my ($meta, $name, $sub) = @_;
    confess "with_meta requires a name and a sub to export"
        unless defined($name) && defined($sub) && ref($sub) eq 'CODE';
    $meta->add_with_meta($name, $sub);
}

sub as_is {
    my ($meta, $name, $sub) = @_;
    confess "as_is requires a name and a sub to export"
        unless defined($name) && defined($sub) && ref($sub) eq 'CODE';
    $meta->add_as_is($name, $sub);
}

sub also {
    my ($meta, @also) = @_;
    $meta->add_also(@also);
}

sub class_metaroles {
    my ($meta, $roles) = @_;
    $meta->class_metaroles($roles);
}

sub role_metaroles {
    my ($meta, $roles) = @_;
    $meta->role_metaroles($roles);
}

sub base_class_roles {
    my ($meta, @roles) = @_;
    $meta->add_base_class_roles(@roles);
}

sub export {
    my ($meta) = @_;
    $meta->setup_exporter;
}

# move this into Moose::Util?
sub with_traits {
    my ($class, @roles) = @_;
    return Moose::Meta::Class->create_anon_class(
        superclasses => [$class],
        roles        => \@roles,
        cache        => 1,
    )->name;
}

sub init_meta {
    my $package = shift;
    my %opts = @_;
    my $meta_name = blessed(Class::MOP::class_of($opts{for_class}))
                 || 'Class::MOP::Package';
    $meta_name = with_traits($meta_name, 'MooseX::Exporter::Easy::Meta::Role::Package');
    my $meta = $meta_name->reinitialize($opts{for_class});
}

1;
