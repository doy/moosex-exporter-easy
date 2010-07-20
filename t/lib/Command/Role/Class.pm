package Command::Role::Class;
use Moose::Role;

sub get_all_commands {
    my ($self) = @_;
    grep { Moose::Util::does_role($_, 'Command::Role::Method') }
         $self->get_all_methods;
}

sub has_command {
    my ($self, $name) = @_;
    my $method = $self->find_method_by_name($name);
    return unless $method;
    return Moose::Util::does_role($method, 'Command::Role::Method');
}

sub get_command {
    my ($self, $name) = @_;
    my $method = $self->find_method_by_name($name);
    return unless $method;
    return Moose::Util::does_role($method, 'Command::Role::Method')
         ? $method
         : ();
}

1;
