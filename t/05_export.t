# $Id: 05_export.t,v 1.3 2005/04/05 15:05:21 jettero Exp $

use strict;
use Test;

use Games::RolePlay::MapGen;
my $map = new Games::RolePlay::MapGen({bounding_box => join("x", 25, 25) });
generate $map;

plan tests => 3 + (25*25);

# if you know of a way to actually test these, you go ahead and email me, ok?

set_exporter $map("Text");
export $map("map.txt"); 
ok( -f "map.txt" );

set_exporter $map("BasicImage");
export $map("map.png"); 
ok( -f "map.png" );


# However, this I could actually test... if I got around to it.

set_exporter $map("XML");
export $map("map.xml"); 
ok( -f "map.xml" );

use XML::Simple;

open IN, "map.xml" or die $!;
my $xmap = XMLin( join("\n", <IN>) )->{'map'}; close IN;

use Data::Dumper;
die Dumper( $xmap );
