package FileAttributes;
use MooseX::Exporter::Easy;
use MooseX::Types::Path::Class qw(File Dir);

with_meta has_file => sub {
    my ($meta, $name, %options) = @_;
    $meta->add_attribute(
        $name,
        is     => 'ro',
        isa    => File,
        coerce => 1,
        %options,
    );
};

with_meta has_dir => sub {
    my ($meta, $name, %options) = @_;
    $meta->add_attribute(
        $name,
        is     => 'ro',
        isa    => Dir,
        coerce => 1,
        %options,
    );
};

export;

1;
