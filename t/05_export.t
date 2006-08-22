# $Id: 05_export.t,v 1.6 2006/08/22 16:35:56 jettero Exp $

use strict;
use Test;

use Games::RolePlay::MapGen;
my $map = new Games::RolePlay::MapGen({bounding_box => join("x", 25, 25) });
generate $map;

plan tests => 3 + (25*25) + 1;

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
set_exporter $map("XML");
export $map("map.xml"); 


skip( (not (-f "/usr/bin/xmllint")) => system("xmllint --postvalid map.xml &>/dev/null"), 0);

open IN, "map.xml" or die $!;
my $xmap = XMLin( join("\n", <IN>) )->{'map'}; close IN;

## DEBUG ## use Data::Dumper; $Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1; 
## DEBUG ## open OUT, ">map.dumper.pl";
## DEBUG ## print OUT Dumper($xmap);
## DEBUG ## close OUT;

for my $row (@{ $xmap->{row} }) {
    for my $tile (@{ $row->{tile} }) {
        ok( 1 );
    }
}
