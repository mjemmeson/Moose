#!/usr/bin/perl

use strict;
use warnings;

use lib 't/lib';

use Test::More;
use Test::Exception;

use MetaTest;

{
    package MyHomePage;
    use Moose;

    has 'counter' => (
        traits  => ['Counter'],
        is      => 'ro',
        isa     => 'Int',
        default => 0,
        handles => {
            inc_counter   => 'inc',
            dec_counter   => 'dec',
            reset_counter => 'reset',
        }
    );
}

my $page = MyHomePage->new();
isa_ok( $page, 'MyHomePage' );

can_ok( $page, $_ ) for qw[
    counter
    dec_counter
    inc_counter
    reset_counter
];

skip_meta {
   lives_ok {
       $page->meta->remove_attribute('counter');
   }
   '... removed the counter attribute okay';

   ok( !$page->meta->has_attribute('counter'),
       '... no longer has the attribute' );

   ok( !$page->can($_), "... our class no longer has the $_ method" ) for qw[
       counter
       dec_counter
       inc_counter
       reset_counter
   ];
} 6;

done_testing;
