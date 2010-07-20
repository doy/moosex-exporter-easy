#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use lib 't/lib';

{
    package Foo;
    use Moose;
    use Command;

    sub foo {
    }

    command bar => sub {
    };
}

ok(Foo->meta->has_method('bar'));
is_deeply([Foo->meta->get_all_commands], [Foo->meta->get_method('bar')]);
ok(Foo->meta->has_command('bar'));
ok(!Foo->meta->has_command('foo'));

done_testing;
