use strict;
use warnings;

use Test::Fatal;
use Test::Moose qw( with_immutable );
use Test::More;

BEGIN {
    plan skip_all => 'These tests requires Specio, which requires perl 5.010'
        unless $] >= 5.010;
}

use Test::Requires {
    'Specio::Declare'           => '0.10',
    'Specio::Library::Builtins' => '0.10',
};

{
    package Foo;

    use Moose;
    use Specio::Library::Builtins;

    has int => (
        is  => 'ro',
        isa => t('Int'),
    );

    has array_of_ints => (
        is  => 'ro',
        isa => t( 'ArrayRef', of => t('Int') ),
    );

    has hash_of_ints => (
        is  => 'ro',
        isa => t( 'HashRef', of => t('Int') ),
    );
}

with_immutable(
    sub {
        my $is_immutable = shift;
        subtest(
            'Foo class' . ( $is_immutable ? ' (immutable)' : q{} ),
            sub {

                is(
                    exception { Foo->new( int => 42 ) },
                    undef,
                    '42 is an acceptable int'
                );

                my $exception_class = 'Moose::Exception::'
                    . (
                    $is_immutable
                    ? 'ValidationFailedForInlineTypeConstraint'
                    : 'ValidationFailedForTypeConstraint'
                    );

                isa_ok(
                    exception { Foo->new( int => 42.4 ) },
                    $exception_class,
                );

                is(
                    exception { Foo->new( array_of_ints => [ 42, 84 ] ) },
                    undef,
                    '[ 42, 84 ] is an acceptable array of ints'
                );

                isa_ok(
                    exception { Foo->new( array_of_ints => [ 42.4, 84 ] ) },
                    $exception_class,
                );

                is(
                    exception {
                        Foo->new( hash_of_ints => { foo => 42, bar => 84 } );
                    },
                    undef,
                    '{ foo => 42, bar => 84 } is an acceptable array of ints'
                );

                isa_ok(
                    exception {
                        Foo->new(
                            hash_of_ints => { foo => 42.4, bar => 84 } );
                    },
                    $exception_class,
                );
            }
        );
    },
    'Foo'
);

{
    package Bar;

    use Moose;
    use Specio::Declare;
    use Specio::Library::Builtins;

    my $array_of_ints = anon( parent => t( 'ArrayRef', of => t('Int') ) );

    coerce(
        $array_of_ints,
        from  => t('Int'),
        using => sub {
            return [ $_[0] ];
        }
    );

    has array_of_ints => (
        is     => 'ro',
        isa    => $array_of_ints,
        coerce => 1,
    );

    my $hash_of_ints = anon( parent => t( 'HashRef', of => t('Int') ) );

    coerce(
        $hash_of_ints,
        from  => t('Int'),
        using => sub {
            return { foo => $_[0] };
        }
    );

    has hash_of_ints => (
        is     => 'ro',
        isa    => $hash_of_ints,
        coerce => 1,
    );
}

with_immutable(
    sub {
        my $is_immutable = shift;
        subtest(
            'Bar class' . ( $is_immutable ? ' (immutable)' : q{} ),
            sub {

                is(
                    exception { Bar->new( array_of_ints => [ 42, 84 ] ) },
                    undef,
                    '[ 42, 84 ] is an acceptable array of ints'
                );

                my $exception_class = 'Moose::Exception::'
                    . (
                    $is_immutable
                    ? 'ValidationFailedForInlineTypeConstraint'
                    : 'ValidationFailedForTypeConstraint'
                    );

                isa_ok(
                    exception { Bar->new( array_of_ints => [ 42.4, 84 ] ) },
                    $exception_class,
                );

                {
                    my $bar;
                    is(
                        exception { $bar = Bar->new( array_of_ints => 42 ) },
                        undef,
                        '42 is an acceptable array of ints with coercion'
                    );

                    is_deeply(
                        $bar->array_of_ints(),
                        [42],
                        'int is coerced to single element arrayref'
                    );
                }

                is(
                    exception {
                        Bar->new( hash_of_ints => { foo => 42, bar => 84 } );
                    },
                    undef,
                    '{ foo => 42, bar => 84 } is an acceptable array of ints'
                );

                isa_ok(
                    exception {
                        Bar->new(
                            hash_of_ints => { foo => 42.4, bar => 84 } );
                    },
                    $exception_class,
                );

                {
                    my $bar;
                    is(
                        exception { $bar = Bar->new( hash_of_ints => 42 ) },
                        undef,
                        '42 is an acceptable hash of ints with coercion'
                    );

                    is_deeply(
                        $bar->hash_of_ints(),
                        { foo => 42 },
                        'int is coerced to single element hashref'
                    );
                }
            }
        );
    },
    'Bar'
);

done_testing();
