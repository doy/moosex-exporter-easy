#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Exception;
use lib 't/lib';

{
    package Foo;
    use Moose;
    use FileAttributes;

    has_file 'foo';
    has_dir  'bar' => (required => 1);
}

my $foo = Foo->new(bar => '.');
isa_ok($foo->bar, 'Path::Class::Dir');

throws_ok { Foo->new(foo => 'test.pl') } qr/required/, "bar is required";

done_testing;
