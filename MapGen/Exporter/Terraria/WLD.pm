package Games::RolePlay::MapGen::Exporter::Terraria::WLD;

use common::sense;  # works every time!
use Carp;
use Games::RolePlay::MapGen::GeneratorPlugin::Terraria qw( add_to_tile frame_info tile_convert );
use Games::RolePlay::MapGen::Tools qw( random );
use Data::Dumper;

use Date::Parse;
use Time::Local;

use subs qw(bool);
use parent qw(Games::RolePlay::MapGen::Exporter);

sub check_opts {
   my ($this, $opts) = @_;
   my ($mx, $my) = map { $opts->{'pixel_'.$_.'_size'} } qw(x y);
   
   # Plenty of defaults here...
   my $dopts = {
      world_name => $opts->{fname},
      spawn_tile => '0,0',  # will re-calc after this...
      surface    => int($my / 3),
      rock_layer => int($my / 3 * 2),
      'time'     => "8:00AM",
      moon_phase => 0,  # 0-7, http://moonphases.info/images/moon-phases-diagram.gif
      blood_moon => 0,
      dungeon    => int($mx / 3).','.int($opts->{'surface'} || $my / 3),
      boss_down  => '0,0,0',
      shadow_orb => 0,
      spawn_meteor => 0,
      invasion   => '0,0,0,0',
   };
   
   $dopts->{world_name} =~ s/^.*[\/\\]|\.wld$//gi;
   
   # find an appropriate spawn
   my $map = $opts->{_the_map};
   foreach my $y (0 .. $#$map) {
      my $xend = $#{$map->[$y]};

      foreach my $x (0 .. $xend) {
         my $t  = $map->[$y][$x];
         next unless ($t->{type});
         next unless (scalar(grep { $t->{od}{$_} } qw(n s w e)) == 1);  # find a dead-end
         
         $dopts->{spawn_tile} = "$x,$y";  # found a good home
         last;
      }
   }

   map { $opts->{$_} //= $dopts->{$_} } keys %$dopts;
   
   # adding spawn tile to objects
   my ($x, $y) = split(/\s*,\s*/, $opts->{spawn_tile});
   add_to_tile($map->[$y][$x], $opts->{_the_queue}, "Spawn Point", 'tile');   
   
   ### FIXME: need sanity checks ###
      
   # 54000 limit for 12 hours
   my $time = (str2time($opts->{'time'}) - timelocal(0,0,0, (localtime(time))[3..5])) * 1.25;  # 86400sec/day --> 108000 game ticks/day
   $time = 36000 if ($time < 0);
   $opts->{'daytime'} = 1;
   
   if ($time > 54000) {
      $time -= 54000;
      $opts->{'daytime'} = 0;
   }
   $opts->{'time'} = $time;
}

sub genmap {
   my ($this, $opts) = @_;
   $this->gen_cell_size($opts);
   $this->check_opts($opts);

   # Do it!
   my $tmap = tile_convert($opts);
   
   # Okay, now for the easy part...
   my ($mx, $my) = map { $opts->{'pixel_'.$_.'_size'} } qw(x y);
   my $id = random(2 ** 32);
   my $wld = '';

   ### Tiles, Walls, and Liquid layers ###   4 to 12 bytes per tile
   # (yep, we're doing this backwards; just so that we can find the spawn point)
   foreach my $x (0 .. $mx-1) {
      foreach my $y (0 .. $my-1) {
         my $t = { map { $_ => frame_info($tmap->{$_}[$x][$y]) } qw(liquid wall tile) };
         my $tb = $t->{tile};
         
         # Special case: The Spawn Point
         if ($tb && $tb->{name} eq 'Spawn Point') {
            $opts->{spawn_xy} ||= "$x,".int($y+2);  # get the bottom-left corner
            undef $tb;  # not a real tile
         }
         
         $wld .= pack('b1', bool $tb);
         
         ### Tiles ###
         # if (IsActive = Boolean) {
         #    Type = Byte
         #    if ([Type].IsFramed) Frame = PointShort(Int16, Int16)
         # }
         if ($tb) {
            $wld .= pack('C', $tb->{num});
            $wld .= pack('SS', split(/,/, $tb->{frame_xy}[$x][$y] || '0,0')) if ($tb->{type} eq 'frame' || $tb->{isFramed});
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
   croak "No spawn point!" unless ($opts->{spawn_xy});
   
   ### Header ###  105+s bytes
   
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
      c3    # IsBossDowned1-3    = Boolean x 3
      c     # IsShadowOrbSmashed = Boolean
      c     # IsSpawnMeteor      = Boolean
      C     # ShadowOrbCount     = Byte
      L     # InvasionDelay      = Int32
      L     # InvasionSize       = Int32
      L     # InvasionType       = Int32
      d     # InvasionX          = Double
   )<";     # Make these little-endian (per Windows standard)
   
   my $wld_head = pack($pack_head,
      20,             # Version
      $opts->{world_name},
      $id,            # WorldId
      0, $mx-1, 0, $my-1, # WorldBounds
      $mx, $my,       # MaxXY
      split(/\s*,\s*/, $opts->{spawn_xy}),
                       $opts->{surface},
                       $opts->{rock_layer},
                       $opts->{'time'},
      bool             $opts->{daytime},
                       $opts->{moon_phase},
      bool             $opts->{blood_moon},
      split(/\s*,\s*/, $opts->{dungeon}),
      map { bool $_ } split(/\s*,\s*/, $opts->{boss_down}),
      bool             $opts->{shadow_orb},
      bool             $opts->{spawn_meteor},
                       $opts->{shadow_orb},
      split(/\s*,\s*/, $opts->{invasion}),
   );
   # (don't forget to link up the Tile data we just collected)
   $wld = $wld_head.$wld;

   ### Chests, Signs, NPCs ###
   
   # if (Boolean) {
   #    Location = PointInt32(Int32, Int32)
   # 
   #    for (1 .. MaxItems) {  # MaxItems = 20
   #       if (stackSize = Byte > 0) itemName = String
   #    }
   # }
   $wld .= pack('x2001');  ### FIXME: Support chests/signs/NPCs ###

   ### Footer ###  6+s bytes

   # TRUE      = Boolean
   # WorldName = String
   # WorldId   = Int32
   $wld .= pack('b1C/A*L', 1, $opts->{world_name}, $id);
   
   return $wld;
}

sub bool (*) { $_[0] ? 1 : 0 }

1;
