#!/usr/bin/perl -w -Iblib/lib
# vi:tw=0:

BEGIN { system("make || (perl Makefile.PL && make)") == 0 or die }

use strict;
use GD;
use Games::RolePlay::MapGen;

# &import_vis1;
# &std_generate;
# &obr_generate;
  &quickx_generate;

system("cp MapGen.dtd ~/www/MapGen.dtd") == 0 or die;
system("cp MapGen.xsl ~/www/MapGen.xsl") == 0 or die;
system("cp map.xml    ~/www/MapGen.xml") == 0 or die;
system("cp map.png    ~/www/MapGen.png") == 0 or die;
system("chmod 644     ~/www/MapGen.*")   == 0 or die;

sub import_vis1 {
    my $map = Games::RolePlay::MapGen->import_xml( "vis1.map.xml" );
       $map->set_exporter( "BasicImage" );
       $map->export( "map.png" );

    ## DEBUG ## use Data::Dumper; $Data::Dumper::Indent = $Data::Dumper::Sortkeys = $Data::Dumper::Maxdepth = 1;
    ## DEBUG ## die Dumper( $map->{_the_map}[ 1 ][ 1 ] );

    exec qw(xv -geometry +0+0 map.png);
}

sub obr_generate {
    my $map = new Games::RolePlay::MapGen({
        tile_size    => 10,
        cell_size    => "23x23", 
        bounding_box => "15x15",
    });

    $map->set_generator("OneBigRoom");
    $map->set_exporter( "BasicImage" );

    $map->generate; 
    $map->export( "map.png" );

    exec qw(xv -geometry +0+0 map.png);
}

sub quickx_generate {
  my $map = Games::RolePlay::MapGen->new({
      tile_size => 10,

      cell_size=>
          "23x23", 
          # "30x30", 
          # "24x32", 
          # "80x80", 

      num_rooms=>
          # "70d4", 
          # "3d8", 
            "2d4", 
          # "1d4", 

      bounding_box => 
          # "12x9",
          # "15x15",
            "20x20",
          # "40x27",
  }); 

  $map->generate; 
  $map->set_exporter( "XML" );
  $map->export( "map.xml" );

  my $map2 = Games::RolePlay::MapGen->import_xml( "map.xml" );
     $map2->set_exporter( "XML" );
     $map2->export( "map2.xml" );
}

sub std_generate {
  my $map = Games::RolePlay::MapGen->new({
      tile_size => 10,

      cell_size=>
          "23x23", 
          # "30x30", 
          # "24x32", 
          # "80x80", 

      num_rooms=>
          # "70d4", 
          # "3d8", 
            "2d4", 
          # "1d4", 

      bounding_box => 
          # "12x9",
          # "15x15",
            "20x20",
          # "40x27",
  }); 

  $map->add_generator_plugin( "FiveSplit" );
  $map->add_generator_plugin( "BasicDoors" ); # this should work with basicdoors first or last!

  $map->generate; 
  $map->export( "map.txt" );
  $map->export( "map.map" );
  
  $map->set_exporter( "BasicImage" );
  $map->export( "map.png" );

  $map->set_exporter( "XML" );
  $map->export( "map.xml" );

  exec qq(xv -geometry +0+0 map.png);
}
