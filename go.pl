#!/usr/bin/perl -Iblib/lib
# $Id: go.pl,v 1.8 2005/04/03 17:30:12 jettero Exp $
# vi:tw=0:

BEGIN { system("make") == 0 or die }

use strict;
use Games::RolePlay::MapGen;

  my $map = new Games::RolePlay::MapGen({
      cell_size=>
          # "20x20", 
          "30x30", 
          # "80x80", 
      num_rooms=>
          # "70d4", 
          "3d8", 
          # "2d4", 

      bounding_box => 
          # "3x3"
          # "12x12"
          "30x30"
          # "63x22"
          # "50x37"
          # "100x100"
  }); 

  add_generator_plugin $map "BasicDoors";
  set_visualization    $map "BasicImage";

  generate  $map; 
  visualize $map "map.png";

system("xv -geometry +0+0 map.png &");
# system("scp map.png voltar.org:tmp/") == 0 or die


__END__

make || exit 1

# perl -Iblib/lib -MExtUtils::Command::MM -e 'test_harness(0, "blib/lib", "blib/arch")' t/05_save*.t || exit 1

# rm -fv *.map
# perl "-MExtUtils::Command::MM" "-e" "test_harness(0, 'blib/lib', 'blib/arch')" t/07*.t
       

# perl -Iblib/lib -MExtUtils::Command::MM -e 'test_harness(0, "blib/lib", "blib/arch")' t/05*.t || exit 1
# perl -Iblib/lib -MExtUtils::Command::MM -e 'test_harness(0, "blib/lib", "blib/arch")' t/07*.t || exit 1

# perl -d:DProf -Iblib/lib -MGames::RolePlay::MapGen -e \
# 'my $map = new Games::RolePlay::MapGen({num_rooms=>"3d8", bounding_box => "63x22"}); 
# generate $map; visualize $map("map.txt");' || exit 1
# 
# rm -vf script
# mkfifo script
# echo 030j61lrj:wqa > script &
# vi -s script map.txt
# rm -vf script

# cat map.txt || exit 1
