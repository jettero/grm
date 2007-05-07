#!/usr/bin/perl -w -Iblib/lib
# vi:tw=0:

BEGIN { system("make || (perl Makefile.PL && make)") == 0 or die }

use strict;
use GD;
use Games::RolePlay::MapGen;
use Games::RolePlay::MapGen::Queue;

&queue_play;
# &std_generate;
# &obr_generate;

system("cp MapGen.dtd ~/www/MapGen.dtd") == 0 or die;
system("cp MapGen.xsl ~/www/MapGen.xsl") == 0 or die;
system("cp map.xml    ~/www/MapGen.xml") == 0 or die;
system("cp map.png    ~/www/MapGen.png") == 0 or die;
system("chmod 644     ~/www/MapGen.*")   == 0 or die;

sub queue_play {
    my $map = new Games::RolePlay::MapGen({
        tile_size    => 10,
        cell_size    => "23x23", 
        bounding_box => "15x15",
        num_rooms    => "1d4",
    });

    warn "importing";
    $map->set_generator( "XMLImport" );
    $map->generate( xml_input_file => "vis1.xml" ); 

    warn "drawing";
    $map->set_exporter( "BasicImage" );
    $map->export( "map.png" );

    warn "marking";
    my $queue = $map->queue;

    warn "redir stderr>log";
    open STDERR, ">log" or die $!;

    # $queue->_lline_of_sight( [22,17]=>[21,16] );
    # $queue->_lline_of_sight( [22,17]=>[24,21] );
    # die;

    my @things = map { my $b = $_; bless \$b, "Thing$b" } ( 1 .. 10 );

    $queue->add( $_ => ($queue->random_open_location) ) for @things;

    my @all = $queue->all_open_locations;
     # @all = ([22,17], [3,19]);

    for my $dp (@all) {
        my $image = GD::Image->new("map.png");
        my $dude1 = $image->colorAllocate(100, 100, 255);
        my $dude2 = $image->colorAllocate(0, 0, 0);
        my $item1 = $image->colorAllocate(255, 255, 0);
        my $item2 = $image->colorAllocate(0, 0, 0);

        my $visible = $image->colorAllocate(220, 255, 220);
        my $igcover = $image->colorAllocate(220, 220, 255);
        my $cover   = $image->colorAllocate(255, 220, 220);

        my @dude_position = @$dp;

        # color visible tiles
        for my $loc ($queue->locations_in_line_of_sight( @dude_position )) {
            my $los = $queue->lline_of_sight( @dude_position => @$loc );
            my $LoS = $visible;
               $LoS = $igcover if $los == LOS_IGNORABLE_COVER;
               $LoS = $cover   if $los == LOS_COVER;

            $image->rectangle(23*$loc->[0]+1, 23*$loc->[1]+1, 23*($loc->[0]+1)-1, 23*($loc->[1]+1)-1, $LoS);
            $image->fill(23*$loc->[0]+2, 23*$loc->[1]+2, $LoS); # the fill is separate because of doors
        }

        # draw things
        for(@things) {
            my $loc = $queue->location( $_ );
            $image->filledEllipse(23*$loc->[0]+12, 23*$loc->[1]+12, 9, 9, $item1);
            $image->ellipse(23*$loc->[0]+12, 23*$loc->[1]+12, 9, 9, $item2);
        }

        # draw the dude
        $image->filledEllipse(23*$dude_position[0]+12, 23*$dude_position[1]+12, 9, 9, $dude1);
        $image->ellipse(23*$dude_position[0]+12, 23*$dude_position[1]+12, 9, 9, $dude2);

        open my $marked, ">marked.png";
        print $marked $image->png;
        close $marked;

        EXEC: {
            unless(@all>5) {
                system(qw(xv -geometry +0+0 marked.png)) == 0 or exit 1;
            }

            system(qw(pngcrush marked.png), sprintf('marked_%02d-%02d.png', @$dp)) == 0 or exit 1;
        }
    }
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
