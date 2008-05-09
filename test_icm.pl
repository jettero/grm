#!/usr/bin/perl

use strict;

my $map = [ [1,2,3],
            [1,2,3],
            [1,2,3] ];

tie @$_, 'Games::RolePlay::MapGen::_disallow_autoviv', $_ for $map, @$map;

eval { $map->[ 0 ][ 0 ]; }; warn "crap: $@" if $@;
eval { $map->[ 2 ][ 3 ]; }; warn "crap: didn't work" unless $@;
eval { $map->[ 3 ][ 0 ]; }; warn "crap: didn't work" unless $@;

package Games::RolePlay::MapGen::_disallow_autoviv;

use strict;
use Tie::Array;
use base 'Tie::StdArray';
use Carp;

sub TIEARRAY {
    my $class = shift;
    my $this  = bless [], $class;
    my $that  = shift;

    @$this = @$that;

    $this;
}

sub FETCH {
    my $this = shift;
    
    croak "autovivifing new rows and columns is disabled ($_[0]>$#$this)" if $_[0] > $#$this;

    $this->SUPER::FETCH(@_);
}
