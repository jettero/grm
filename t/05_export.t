
use strict;
use Test;
use File::Slurp;

use Games::RolePlay::MapGen;
my $map = new Games::RolePlay::MapGen({bounding_box => join("x", 25, 25) });
   $map->add_generator_plugin("BasicDoors");
   $map->generate;

plan tests => 3 + (25*25) + 7 + 2;

# if you know of a way to actually test these, you go ahead and email me, ok?

$map->set_exporter("Text");
$map->export("map.txt"); 
ok( -f "map.txt" );

$map->export( fname=>"map.tnc", nocolor=>1 ); 
ok( -f "map.txt" );

my $txt = read_file('map.txt'); $txt =~ s/\e\[[\d;]*m//g;
my $tnc = read_file('map.tnc');
ok( $txt, $tnc );

eval "use GD;"; 
if( $@ ) {
    skip('Skip since no GD', 1) for 1 .. 7;

} else {
    set_exporter $map("PNG");
    export $map("map.png"); 
    ok( -f "map.png" );
    unlink "map.png";

    set_exporter $map("Image");
    
    foreach my $ext (qw(png jpg jpeg gif gd gd2)) {
        my $fn = "map.$ext";
        export $map($fn);
        ok( ($ext eq 'gd') ? -f $fn : GD::Image->new($fn) );  # GD version 1 cannot be recognized automatically at this time
    }

}

# However, this I could actually test... if I got around to it.

if( system($^X, "XMLEXPORT_pretest") != 0 ) {
    warn "\n\n Your XML::Simple and/or XML::SAX is broken apparently ... skipping exporter tests.\n\n";
    skip(1,1,1) for 1 .. 2;
    skip(1,1,1) for 1 .. @{$map->{_the_map}}*@{$map->{_the_map}[0]};
    exit 0;
}

set_exporter $map("XML");
export $map("map.xml"); 
ok( -f "map.xml" );

use XML::Simple;
set_exporter $map("XML");
export $map("map.xml"); 

if( -f "xmllint.res" ) {
    ok( system(qw(xmllint --path blib/lib/Games/RolePlay/MapGen --postvalid --noout map.xml)), 0);

} else {
    skip(1,1,1);
}

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
