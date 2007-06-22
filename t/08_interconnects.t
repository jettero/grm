
use strict;
use Test;

my ($x, $y) = (25, 25);

plan tests => (2*4 * $x * $y);

use Games::RolePlay::MapGen;

my $map = new Games::RolePlay::MapGen({ num_rooms=>"2d4", bounding_box=>join("x", $x, $y) });

$map->set_generator("Basic");
$map->add_generator_plugin("BasicDoors");

generate $map;
if( 0 ) {
    $map->set_exporter( "BasicImage" );
    save_map $map("map.map");         # these are for when the tests fail and you don't know why ...
    print STDERR " saved map.map\n";  # but we don't normally need them.
}

CHECK_OPEN_DIRECTIONS_FOR_SANITY: { # they should really be the same from each direction ... or there's a problem.
    my $m = $map->{_the_map};
    for my $i (0..$y-1) {
        for my $j (0..$x-1) {
            my $here = $m->[$i][$j];

            for my $ar ( [n=>[y=>$i-1]], [s=>[y=>$i+1]], [e=>[x=>$j+1]], [w=>[x=>$j-1]] ) {
                my $d = $ar->[0];
                my ($k, $v) = @{$ar->[1]};

                if( my $n = $here->{nb}{$d} ) {
                    my $o = $Games::RolePlay::MapGen::opp{$d};
                    my $r = $n->{nb}{$o} == $here;

                    # warn "$d:[$k,$v]";

                    ok( $r );
                    ok( $n->{$k}, $v );

                } else {
                    ok(1);
                    ok(1);
                }
            }
        }
    }
}
