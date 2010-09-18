package Moose::Meta::Method::Accessor::Native::Array::map;

use strict;
use warnings;

our $VERSION = '1.13';
$VERSION = eval $VERSION;
our $AUTHORITY = 'cpan:STEVAN';

use base 'Moose::Meta::Method::Accessor::Native::Array::Reader';

sub _minimum_arguments { 1 }

sub _maximum_arguments { 1 }

sub _inline_check_arguments {
    my $self = shift;

    return $self->_inline_throw_error(
        q{'The argument passed to map must be a code reference'})
        . q{if $_[0] && ( ref $_[0] || q{} ) ne 'CODE';};
}

sub _return_value {
    my $self        = shift;
    my $slot_access = shift;

    return "map { \$_[0]->() } \@{ $slot_access }";
}

1;