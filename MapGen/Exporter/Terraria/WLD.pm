package Games::RolePlay::MapGen::Exporter::Terraria::WLD;

use common::sense;  # ...  it works every time!
use Data::Dumper;
use List::Util qw(shuffle);
use Games::RolePlay::MapGen::GeneratorPlugin::Terraria qw(tile_convert);
use Games::RolePlay::MapGen::MapQueue;
use Games::RolePlay::MapGen::Tools qw( random );

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
   my $wld = pack($pack_head, 20, "GRM World", random(2 * 32), 0, $opts->{x_size}, 0, $opts->{y_size}, $opts->{x_size}, $opts->{y_size}, undef, 
                  # ...WorldSurface
                  undef, undef, undef, 1, 0, 0, undef, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  
   foreach my $x (0 .. $#$tmap) {
      my $yend = $#{$tmap->[$x]};

      foreach my $y (0 .. $yend) {
         my $t  = $map->[$x][$y];
         
         if (IsActive = Boolean) {
   
   
   # unpack uses c/(), pack uses ()[c]
   # serves as a conditional, but with different orders
   tile_unpack => "
      c/(    # if (IsActive = Boolean) {
      C      #    Type = Byte
      {SS}   #    if ([Type].IsFramed) Frame = PointShort(Int16, Int16)
      }      # }
      c      # IsLighted = Boolean
      c{C}   # if (Boolean) Wall = Byte
      c{     # if (Boolean) {
      C      #    Liquid = Byte
      c      #    IsLava = Boolean
      }      # }
   ",

   # if (Boolean) {
   #    Location = PointInt32(Int32, Int32)
   # 
   #    for (1 .. MaxItems) {  # MaxItems = 20
   #       if (stackSize = Byte > 0) itemName = String
   #    }
   # }


   chest        => '(L2((CC/A*)[&])[20])[&]',
   sign  => "",
   npc   => "",
   

   return $wld;
}

1;

use v5.10;
say unpack("b1/(a8)", "\001Gurusamy");
say unpack("c/(aaaaaaaa)", "\001Gurusamy");
say join ',', unpack("c/(C8)", "\001Gurusamy");

say pack("c/(ALdd)",     0, 'G', 75, 75, 75);
say pack("c/(aaaaaaaa)", 1, split(//, "Gurusamy"));
say pack("(C8)[1]", 71,117,114,117,115,97,109,121);

