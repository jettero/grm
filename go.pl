#!/usr/bin/perl -w -Iblib/lib
# vi:tw=0:

BEGIN { system("make || (perl Makefile.PL && make)") == 0 or die }

use strict;
use Games::RolePlay::MapGen;

# &std_generate;
# &obr_generate;

system("cp MapGen.dtd ~/www/MapGen.dtd") == 0 or die;
system("cp MapGen.xsl ~/www/MapGen.xsl") == 0 or die;
system("cp map.xml    ~/www/MapGen.xml") == 0 or die;
system("cp map.png    ~/www/MapGen.png") == 0 or die;
system("chmod 644     ~/www/MapGen.*")   == 0 or die;

sub queue_play {
    my $map = new Games::RolePlay::MapGen({
        tile_size    => 5,
        cell_size    => "23x23", 
        bounding_box => "15x15",
    });

    $map->set_generator("OneBigRoom");
    $map->generate; 
}

sub obr_generate {
    my $map = new Games::RolePlay::MapGen({
        tile_size    => 10,
        cell_size    => "23x23", 
        bounding_box => "15x15",
    });

    $map->set_generator("OneBigRoom");
    $map->set_exporter( "BasicImage" );       # But a graphical map is probably more useful.

    $map->generate; 
    $map->export( "map.png" );

    exec qw(xv map.png);
}

sub std_generate {
  my $map = new Games::RolePlay::MapGen({
      tile_size => 10,

      cell_size=>
          "23x23", 
          # "30x30", 
          # "24x32", 
          # "80x80", 

      num_rooms=>
          # "70d4", 
          # "3d8", 
          # "2d4", 
            "1d4", 

      bounding_box => 
          # "12x9"
            "15x15"
          # "30x14"
          # "40x27"
  }); 

  add_generator_plugin $map "FiveSplit";
  add_generator_plugin $map "BasicDoors"; # this should work with basicdoors first or last!

  generate $map; 
  export   $map "map.txt";
  save_map $map "map.map";

  set_exporter $map "BasicImage";
  export       $map "map.png";

  set_exporter $map "XML";
  export       $map "map.xml";

  $map = Games::RolePlay::MapGen->new();
  $map->set_generator("XMLImport");
  $map->generate( xml_input_file => "map.xml" );
  $map->set_exporter( "XML" );
  $map->export( "ma2.xml" );

  # exec qq(diff -u map.xml ma2.xml | vim --cmd 'let no_plugin_maps = 1' -c 'runtime! macros/less.vim' -c 'set fdl=99' -);
}
