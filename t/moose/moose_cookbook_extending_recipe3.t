#!/usr/bin/perl -w

use strict;
use Test::More 'no_plan';
use Test::Exception;
$| = 1;



# =begin testing SETUP
BEGIN {
    eval 'use Test::Output;';
    if ($@) {
        diag 'Test::Output is required for this test';
        ok(1);
        exit 0;
    }
}



# =begin testing SETUP
{

  package MyApp::Base;
  use Moose;

  extends 'Moose::Object';

  before 'new' => sub { warn "Making a new " . $_[0] };

  no Moose;

  package MyApp::UseMyBase;
  use Moose ();
  use MooseX::Exporter::Easy;

  also 'Moose';

  sub init_meta_extra {
      shift;
      return Moose->init_meta( @_, base_class => 'MyApp::Base' );
  }

  export;
}



# =begin testing
{
{
    package Foo;

    MyApp::UseMyBase->import;

    has( 'size' => ( is => 'rw' ) );
}

ok( Foo->isa('MyApp::Base'), 'Foo isa MyApp::Base' );

ok( Foo->can('size'), 'Foo has a size method' );

my $foo;
stderr_like(
    sub { $foo = Foo->new( size => 2 ) },
    qr/^Making a new Foo/,
    'got expected warning when calling Foo->new'
);

is( $foo->size(), 2, '$foo->size is 2' );
}




1;
