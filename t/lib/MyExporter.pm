

package MyExporter;
use MooseX::Exporter::Easy;
use Test::More;

with_meta with_prototype => sub (&) {
    my ($meta, $code) = @_;
    isa_ok($code, 'CODE', 'with_prototype received a coderef');
    $code->();
};

as_is as_is_prototype => sub (&) {
    my ($code) = @_;
    isa_ok($code, 'CODE', 'as_is_prototype received a coderef');
    $code->();
};

export;

1;
