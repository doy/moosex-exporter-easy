#!/usr/bin/perl -w

use strict;
use Test::More 'no_plan';
use Test::Exception;
$| = 1;



# =begin testing SETUP
{

  package MyApp::Mooseish;

  use Moose ();
  use MooseX::Exporter::Easy;

  also 'Moose';

  sub init_meta_extra {
      shift;
      return Moose->init_meta( @_, metaclass => 'MyApp::Meta::Class' );
  }

  with_meta has_table => sub {
      my $meta = shift;
      $meta->table(shift);
  };

  export;

  package MyApp::Meta::Class;
  use Moose;

  extends 'Moose::Meta::Class';

  has 'table' => ( is => 'rw' );
}



# =begin testing
{
{
    package MyApp::User;

    MyApp::Mooseish->import;

    has_table( 'User' );

    has( 'username' => ( is => 'ro' ) );
    has( 'password' => ( is => 'ro' ) );

    sub login { }
}

isa_ok( MyApp::User->meta, 'MyApp::Meta::Class' );
is( MyApp::User->meta->table, 'User',
    'MyApp::User->meta->table returns User' );
ok( MyApp::User->can('username'),
    'MyApp::User has username method' );
}




1;
