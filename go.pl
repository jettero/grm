#!/usr/bin/perl -Iblib/lib
# $Id: go.pl,v 1.16 2006/08/21 22:51:16 jettero Exp $
# vi:tw=0:

BEGIN { system("make || (perl Makefile.PL && make)") == 0 or die }

use strict;
use Games::RolePlay::MapGen;

  my $map = new Games::RolePlay::MapGen({
      cell_size=>
          "23x23", 
          # "30x30", 
          # "24x32", 
          # "80x80", 

      num_rooms=>
          # "70d4", 
          "3d8", 
          # "2d4", 

      bounding_box => 
          # "3x3"
          # "15x15"
          "30x30"
          # "63x22"
          # "50x37"
          # "200x200"
  }); 

  add_generator_plugin $map "BasicDoors";
  generate $map; 
  export   $map "map.txt";
  save_map $map "map.map";

  set_exporter $map "BasicImage";
  export       $map "map.png";

  set_exporter $map "XML";
  export       $map "map.xml";

system("xv -geometry +0+0 map.png &") == 0 or die;

# system("pngcrush map.png o.png && mv o.png map.png") == 0 or die;
# system("chmod 0644 map.png") == 0 or die;
# system("scp -Cp map.png voltar.org:tmp/") == 0 or die;

# system("cat map.txt") == 0 or die;
# system("cat map.xml | less -eS") == 0 or die;


__END__

make || exit 1

# perl -Iblib/lib -MExtUtils::Command::MM -e 'test_harness(0, "blib/lib", "blib/arch")' t/05_save*.t || exit 1

# rm -fv *.map
# perl "-MExtUtils::Command::MM" "-e" "test_harness(0, 'blib/lib', 'blib/arch')" t/07*.t
       

# perl -Iblib/lib -MExtUtils::Command::MM -e 'test_harness(0, "blib/lib", "blib/arch")' t/05*.t || exit 1
# perl -Iblib/lib -MExtUtils::Command::MM -e 'test_harness(0, "blib/lib", "blib/arch")' t/07*.t || exit 1

# perl -d:DProf -Iblib/lib -MGames::RolePlay::MapGen -e \
# 'my $map = new Games::RolePlay::MapGen({num_rooms=>"3d8", bounding_box => "63x22"}); 
# generate $map; export $map("map.txt");' || exit 1
# 
# rm -vf script
# mkfifo script
# echo 030j61lrj:wqa > script &
# vi -s script map.txt
# rm -vf script

# cat map.txt || exit 1
