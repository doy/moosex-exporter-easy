#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Output;
use lib 't/lib';

{
    package Foo;
    use Moose;
    use AtomicMethod;

    atomic_method foo => sub {
        warn "in foo\n";
    };
}

my $foo = Foo->new;
stderr_is(sub { $foo->foo }, "locking...\nin foo\nunlocking...\n");

done_testing;
