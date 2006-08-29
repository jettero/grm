#!/usr/bin/perl -Iblib/lib
# $Id: go.pl,v 1.19 2006/08/29 13:25:42 jettero Exp $
# vi:tw=0:

BEGIN { system("make || (perl Makefile.PL && make)") == 0 or die }

use strict;
use Games::RolePlay::MapGen;

&generate;

system("cp MapGen.dtd ~/www/MapGen.dtd") == 0 or die;
system("cp MapGen.xsl ~/www/MapGen.xsl") == 0 or die;
system("cp map.xml    ~/www/MapGen.xml") == 0 or die;
system("cp map.png    ~/www/MapGen.png") == 0 or die;
system("chmod 644     ~/www/MapGen.*")   == 0 or die;

sub generate {
  my $map = new Games::RolePlay::MapGen({
      cell_size=>
          "23x23", 
          # "30x30", 
          # "24x32", 
          # "80x80", 

      num_rooms=>
          # "70d4", 
          # "3d8", 
          "2d4", 

      bounding_box => 
          # "3x3"
          # "15x15"
          "40x27"
          # "63x22"
          # "50x37"
          # "200x200"
  }); 

  add_generator_plugin $map "BasicDoors";
  add_generator_plugin $map "FiveSplit";

  generate $map; 
  export   $map "map.txt";
  save_map $map "map.map";

  set_exporter $map "BasicImage";
  export       $map "map.png";

  set_exporter $map "XML";
  export       $map "map.xml";
}
