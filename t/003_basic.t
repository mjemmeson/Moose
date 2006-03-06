#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 18;
use Test::Exception;

BEGIN {
    use_ok('Moose');           
}

{
    package BinaryTree;
    use strict;
    use warnings;
    use Moose;

    has '$.parent' => (
        predicate => 'has_parent',
        accessor  => 'parent'
    );

    has '$.left' => (
        predicate => 'has_left',         
        accessor  => 'left',
    );

    has '$.right' => (
        predicate => 'has_right',           
        accessor  => 'right',
    );

    before 'right', 'left' => sub {
        my ($self, $tree) = @_;
	    $tree->parent($self) if defined $tree;   
	};
}

my $root = BinaryTree->new();
isa_ok($root, 'BinaryTree');

is($root->left, undef, '... no left node yet');
is($root->right, undef, '... no right node yet');

ok(!$root->has_left, '... no left node yet');
ok(!$root->has_right, '... no right node yet');

my $left = BinaryTree->new();
isa_ok($left, 'BinaryTree');

ok(!$left->has_parent, '... left does not have a parent');

$root->left($left);

is($root->left, $left, '... got a left node now (and it is $left)');
ok($root->has_left, '... we have a left node now');

ok($left->has_parent, '... lefts has a parent');
is($left->parent, $root, '... lefts parent is the root');

my $right = BinaryTree->new();
isa_ok($right, 'BinaryTree');

ok(!$right->has_parent, '... right does not have a parent');

$root->right($right);

is($root->right, $right, '... got a right node now (and it is $right)');
ok($root->has_right, '... we have a right node now');

ok($right->has_parent, '... rights has a parent');
is($right->parent, $root, '... rights parent is the root');
