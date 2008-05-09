#!/usr/bin/perl

use strict;

my $map = {
    bounding_box => '3x3',
    _the_map => [
       [1,2,3],
       [1,2,3],
       [1,2,3],
    ],
};

bless $map->{_the_map}, "icm";
tie @{$map->{_the_map}}, 'icm';

$map->{_the_map}->yeah;
$map->{_the_map}[ 0 ];
$map->{_the_map}[ 3 ];

package icm;

use strict;
use Tie::Array;
use base 'Tie::StdArray';
use Carp;

sub FETCH {
    my $this = shift;
    
    croak "no no no, $_[0] is beyond the end of the map rows" if $_[0]> $#$this;
    print "yeah, fetching($_[0])\n";

    $this->SUPER::FETCH(@_);
}

sub yeah {
    print "yeah\n";
}
