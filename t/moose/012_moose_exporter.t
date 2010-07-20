#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
BEGIN {
    eval "use Test::Output;";
    plan skip_all => "Test::Output is required for this test" if $@;
}


{
    package HasOwnImmutable;

    use Moose;

    no Moose;

    ::stderr_is( sub { eval q[sub make_immutable { return 'foo' }] },
                  '',
                  'no warning when defining our own make_immutable sub' );
}

{
    is( HasOwnImmutable->make_immutable(), 'foo',
        'HasOwnImmutable->make_immutable does not get overwritten' );
}

{
    package MooseX::Empty;

    use Moose ();
    use MooseX::Exporter::Easy;
    also 'Moose';
    export;
}

{
    package WantsMoose;

    MooseX::Empty->import();

    sub foo { 1 }

    ::can_ok( 'WantsMoose', 'has' );
    ::can_ok( 'WantsMoose', 'with' );
    ::can_ok( 'WantsMoose', 'foo' );

    MooseX::Empty->unimport();
}

{
    # Note: it's important that these methods be out of scope _now_,
    # after unimport was called. We tried a
    # namespace::clean(0.08)-based solution, but had to abandon it
    # because it cleans the namespace _later_ (when the file scope
    # ends).
    ok( ! WantsMoose->can('has'),  'WantsMoose::has() has been cleaned' );
    ok( ! WantsMoose->can('with'), 'WantsMoose::with() has been cleaned' );
    can_ok( 'WantsMoose', 'foo' );

    # This makes sure that Moose->init_meta() happens properly
    isa_ok( WantsMoose->meta(), 'Moose::Meta::Class' );
    isa_ok( WantsMoose->new(), 'Moose::Object' );

}

{
    package MooseX::Sugar;

    use Moose ();
    use MooseX::Exporter::Easy;

    also 'Moose';

    with_meta wrapped1 => sub {
        my $meta = shift;
        return $meta->name . ' called wrapped1';
    };

    export;
}

{
    package WantsSugar;

    MooseX::Sugar->import();

    sub foo { 1 }

    ::can_ok( 'WantsSugar', 'has' );
    ::can_ok( 'WantsSugar', 'with' );
    ::can_ok( 'WantsSugar', 'wrapped1' );
    ::can_ok( 'WantsSugar', 'foo' );
    ::is( wrapped1(), 'WantsSugar called wrapped1',
          'wrapped1 identifies the caller correctly' );

    MooseX::Sugar->unimport();
}

{
    ok( ! WantsSugar->can('has'),  'WantsSugar::has() has been cleaned' );
    ok( ! WantsSugar->can('with'), 'WantsSugar::with() has been cleaned' );
    ok( ! WantsSugar->can('wrapped1'), 'WantsSugar::wrapped1() has been cleaned' );
    can_ok( 'WantsSugar', 'foo' );
}

{
    package MooseX::MoreSugar;

    use Moose ();
    use MooseX::Exporter::Easy;

    also 'MooseX::Sugar';

    with_meta wrapped2 => sub {
        my $meta = shift;
        return $meta->name . ' called wrapped2';
    };

    as_is as_is1 => sub {
        return 'as_is1';
    };

    export;
}

{
    package WantsMoreSugar;

    MooseX::MoreSugar->import();

    sub foo { 1 }

    ::can_ok( 'WantsMoreSugar', 'has' );
    ::can_ok( 'WantsMoreSugar', 'with' );
    ::can_ok( 'WantsMoreSugar', 'wrapped1' );
    ::can_ok( 'WantsMoreSugar', 'wrapped2' );
    ::can_ok( 'WantsMoreSugar', 'as_is1' );
    ::can_ok( 'WantsMoreSugar', 'foo' );
    ::is( wrapped1(), 'WantsMoreSugar called wrapped1',
          'wrapped1 identifies the caller correctly' );
    ::is( wrapped2(), 'WantsMoreSugar called wrapped2',
          'wrapped2 identifies the caller correctly' );
    ::is( as_is1(), 'as_is1',
          'as_is1 works as expected' );

    MooseX::MoreSugar->unimport();
}

{
    ok( ! WantsMoreSugar->can('has'),  'WantsMoreSugar::has() has been cleaned' );
    ok( ! WantsMoreSugar->can('with'), 'WantsMoreSugar::with() has been cleaned' );
    ok( ! WantsMoreSugar->can('wrapped1'), 'WantsMoreSugar::wrapped1() has been cleaned' );
    ok( ! WantsMoreSugar->can('wrapped2'), 'WantsMoreSugar::wrapped2() has been cleaned' );
    ok( ! WantsMoreSugar->can('as_is1'), 'WantsMoreSugar::as_is1() has been cleaned' );
    can_ok( 'WantsMoreSugar', 'foo' );
}

{
    package My::Metaclass;
    use Moose;
    BEGIN { extends 'Moose::Meta::Class' }

    package My::Object;
    use Moose;
    BEGIN { extends 'Moose::Object' }

    package HasInitMeta;

    use Moose ();
    use MooseX::Exporter::Easy;

    also 'Moose';

    sub init_meta_extra {
        shift;
        return Moose->init_meta( @_,
                                 metaclass  => 'My::Metaclass',
                                 base_class => 'My::Object',
                               );
    }

    export;
}

{
    package NewMeta;

    HasInitMeta->import();
}

{
    isa_ok( NewMeta->meta(), 'My::Metaclass' );
    isa_ok( NewMeta->new(), 'My::Object' );
}

{
    package MooseX::CircularAlso;

    use Moose ();
    use MooseX::Exporter::Easy;
    also 'Moose', 'MooseX::CircularAlso';

    ::dies_ok(
        sub { export },
        'a circular reference in also dies with an error'
    );

    ::like(
        $@,
        qr/\QCircular reference in 'also' parameter to Moose::Exporter between MooseX::CircularAlso and MooseX::CircularAlso/,
        'got the expected error from circular reference in also'
    );
}

{
    package MooseX::NoAlso;

    use Moose ();
    use MooseX::Exporter::Easy;

    also 'NoSuchThing';

    ::dies_ok(
        sub { export },
        'a package which does not use Moose::Exporter in also dies with an error'
    );

    ::like(
        $@,
        qr/\QPackage in also (NoSuchThing) does not seem to use Moose::Exporter (is it loaded?) at /,
        'got the expected error from a reference in also to a package which is not loaded'
    );
}

{
    package MooseX::NotExporter;

    use Moose ();
    use MooseX::Exporter::Easy;

    also 'Moose::Meta::Method';

    ::dies_ok(
        sub { export },
        'a package which does not use Moose::Exporter in also dies with an error'
    );

    ::like(
        $@,
        qr/\QPackage in also (Moose::Meta::Method) does not seem to use Moose::Exporter at /,
        'got the expected error from a reference in also to a package which does not use Moose::Exporter'
    );
}

{
    package MooseX::OverridingSugar;

    use Moose ();
    use MooseX::Exporter::Easy;

    also 'Moose';

    with_meta has => sub {
        my $meta = shift;
        return $meta->name . ' called has';
    };

    export;
}

{
    package WantsOverridingSugar;

    MooseX::OverridingSugar->import();

    ::can_ok( 'WantsOverridingSugar', 'has' );
    ::can_ok( 'WantsOverridingSugar', 'with' );
    ::is( has('foo'), 'WantsOverridingSugar called has',
          'has from MooseX::OverridingSugar is called, not has from Moose' );

    MooseX::OverridingSugar->unimport();
}

{
    ok( ! WantsSugar->can('has'),  'WantsSugar::has() has been cleaned' );
    ok( ! WantsSugar->can('with'), 'WantsSugar::with() has been cleaned' );
}

{
    package NonExistentExport;

    use Moose ();
    use MooseX::Exporter::Easy;

    also 'Moose';

    ::throws_ok {
        with_meta 'does_not_exist';
    } qr/with_meta requires a name and a sub to export/,
      "dies when a function to export isn't passed";

    export;
}

{
    package WantsNonExistentExport;

    NonExistentExport->import;

    ::ok(!__PACKAGE__->can('does_not_exist'),
         "undefined subs do not get exported");
}

{
    package AllOptions;
    use Moose ();
    use MooseX::Exporter::Easy;

    also 'Moose';

    as_is as_is1 => sub {2};

    with_meta with_meta1 => sub {
        return @_;
    };

    with_meta with_meta2 => sub (&) {
        return @_;
    };

    export;
}

{
    package UseAllOptions;

    AllOptions->import();
}

{
    can_ok( 'UseAllOptions', $_ )
        for qw( with_meta1 with_meta2 as_is1 );

    {
        my ( $meta, $arg1 ) = UseAllOptions::with_meta1(42);
        isa_ok( $meta, 'Moose::Meta::Class', 'with_meta first argument' );
        is( $arg1, 42, 'with_meta1 returns argument it was passed' );
    }

    is(
        prototype( UseAllOptions->can('with_meta2') ),
        prototype( AllOptions->can('with_meta2') ),
        'using correct prototype on with_meta function'
    );
}

{
    package UseAllOptions;
    AllOptions->unimport();
}

{
    ok( ! UseAllOptions->can($_), "UseAllOptions::$_ has been unimported" )
        for qw( with_meta1 with_meta2 as_is1 );
}

done_testing;
