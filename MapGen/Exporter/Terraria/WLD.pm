package Games::RolePlay::MapGen::Exporter::Terraria::WLD;

use common::sense;  # ...  it works every time!
use Data::Dumper;
use List::Util qw(shuffle);
use Games::RolePlay::MapGen::GeneratorPlugin::Terraria qw(tile_convert);
use Games::RolePlay::MapGen::MapQueue;
use Games::RolePlay::MapGen::Tools qw( random );
use subs qw(bool)
use parent qw(Games::RolePlay::MapGen::Exporter);

sub genmap {
   my $this = shift;
   my $opts = shift;
   $this->gen_cell_size($opts);

   # Do it!  DO IT!
   my $tmap = tile_convert($opts);
   
   # Okay, now for the easy part...
   my $pack_head = "(                                                         
      L     # Version            = Int32
      C/A*  # WorldName          = String
      L     # WorldId            = Int32
      L4    # WorldBounds        = RectF(Int32, Int32, Int32, Int32)
      L2    # MaxXY              = PointInt32(Int32, Int32)
      L2    # SpawnTile          = PointInt32(Int32, Int32)
      d     # WorldSurface       = Double
      d     # WorldRockLayer     = Double
      d     # Time               = Double
      c     # IsDayTime          = Boolean
      L     # MoonPhase          = Int32
      c     # IsBloodMoon        = Boolean
      L2    # DungeonEntrance    = PointInt32(Int32, Int32)
      c     # IsBossDowned1      = Boolean
      c     # IsBossDowned2      = Boolean
      c     # IsBossDowned3      = Boolean
      c     # IsShadowOrbSmashed = Boolean
      c     # IsSpawnMeteor      = Boolean
      C     # ShadowOrbCount     = Byte
      L     # InvasionDelay      = Int32
      L     # InvasionSize       = Int32
      L     # InvasionType       = Int32
      d     # InvasionX          = Double
   )<";     # Make these little-endian (per Windows standard)
   
   ### FIXME: Need to add these variables ###
   my $wld = pack($pack_head, 20, "GRM World", my $id = random(2 * 32), 0, $opts->{x_size}, 0, $opts->{y_size}, $opts->{x_size}, $opts->{y_size}, undef, 
                  # ...WorldSurface
                  undef, undef, undef, 1, 0, 0, undef, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  
  # Tiles, Walls, and Liquid layers
  foreach my $x (0 .. $#$tmap) {
      my $yend = $#{$tmap->[$x]};

      foreach my $y (0 .. $yend) {
         my $t = map { $tmap->{$_}[$x][$y] } qw(liquid wall block);
         $wld .= pack('b1', bool $t->{block});
         
         ### Tiles ###
         # if (IsActive = Boolean) {
         #    Type = Byte
         #    if ([Type].IsFramed) Frame = PointShort(Int16, Int16)
         # }
         if (my $tb = $t->{block}) {
            $wld .= pack('C', $tb->{num});
            $wld .= pack('SS', split(/,/, $tb->{frame_xy}[$x][$y])) if ($tb->{type} eq 'frame' || $tb->{isFramed});
         }
         # IsLighted = Boolean
         $wld .= pack('b1', 0);  # still haven't figured out what the hell this property does...
         
         ### Walls ###
         # if (Boolean) Wall = Byte
         $wld .= pack('b1', bool $t->{wall});
         $wld .= pack('C', $t->{wall}{num}) if ($t->{wall});
         
         ### Liquid ###
         # if (Boolean) {
         #    Liquid = Byte
         #    IsLava = Boolean
         # }
         $wld .= pack('b1', bool $t->{liquid});
         if ($t->{liquid}) {
            $wld .= pack('C', 255);  ### TODO: Support liquid levels ###
            $wld .= pack('b1', bool ($t->{liquid}{name} eq 'Lava'));
         }
      }
   }
   
   # if (Boolean) {
   #    Location = PointInt32(Int32, Int32)
   # 
   #    for (1 .. MaxItems) {  # MaxItems = 20
   #       if (stackSize = Byte > 0) itemName = String
   #    }
   # }
   $wld .= pack('x2001');  ### FIXME: Support chests/signs/NPCs ###

   # TRUE      = Boolean
   # WorldName = String
   # WorldId   = Int32
   $wld .= pack('b1C/A*L', 1, "GRM World", $id);
   
   return $wld;
}

sub bool (*) { $_[0] ? 1 : 0 }

1;
