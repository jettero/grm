#!/bin/bash
# $Id: go.sh,v 1.4 2005/03/24 01:17:02 jettero Exp $
# vi:tw=0:

make || exit 1

# perl -Iblib/lib -MExtUtils::Command::MM -e 'test_harness(0, "blib/lib", "blib/arch")' t/05*.t || exit 1

perl -Iblib/lib -MGames::RolePlay::MapGen -e 'my $map = new Games::RolePlay::MapGen({num_rooms=>"3d8", bounding_box => "30x15"}); generate $map; visualize $map("map.txt");'

rm -vf script
mkfifo script
echo 030j61lrj:wqa > script &
vi -s script map.txt
rm -vf script

cat map.txt || exit 1
