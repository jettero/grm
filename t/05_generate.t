# $Id: 05_generate.t,v 1.9 2005/03/24 16:06:55 jettero Exp $

use strict;
use Test;

my ($x, $y) = (63, 22);

plan tests => 1 + (4 * $x * $y);

use Games::RolePlay::MapGen;

my $map = new Games::RolePlay::MapGen({bounding_box => join("x", $x, $y) });

generate $map;

CHECK_OPEN_DIRECTIONS_FOR_SANITY: { # they should really be the same from each direction ... or there's a problem.
    my $m = $map->{_the_map};
    for my $i (0..$y-1) {
        for my $j (0..$x-1) {
            my $here  = $m->[$i][$j]{tile}{od};
            my $above = ( $i ==    0 ? undef : $m->[$i-1][$j]{tile}{od});
            my $below = ( $i == $y-1 ? undef : $m->[$i+1][$j]{tile}{od});
            my $left  = ( $j ==    0 ? undef : $m->[$i][$j-1]{tile}{od});
            my $right = ( $j == $x-1 ? undef : $m->[$i][$j+1]{tile}{od});

            if( $above ) { ok( $above->{s}, $here->{n} ) } else { ok(1) }
            if( $below ) { ok( $below->{n}, $here->{s} ) } else { ok(1) }
            if( $left  ) { ok(  $left->{e}, $here->{w} ) } else { ok(1) }
            if( $right ) { ok( $right->{w}, $here->{e} ) } else { ok(1) }
        }
    }
}

visualize $map ("map.txt");
if( -f "map.txt" ) {
    ok( 1 );

} else {
    ok( 0 );
}
