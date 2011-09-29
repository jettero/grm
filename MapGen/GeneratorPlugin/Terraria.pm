package Games::RolePlay::MapGen::GeneratorPlugin::Terraria;

use v5.10;
use XML::Parser;
use Games::RolePlay::MapGen::MapQueue::Object;
use Games::RolePlay::MapGen::Tools qw( choice random );
use List::Util qw( shuffle );
use Memoize;

use parent Exporter;
our @EXPORT_OK = qw(odds_pick add_to_tile frame_info);

##############################################################################

my $xml_path = $INC{'Games/RolePlay/MapGen/GeneratorPlugin/Terraria.pm'};
   $xml_path =~ s/\.pm$//;

$Games::RolePlay::MapGen::known_opts{'terraria_settings_xml'} = "$xml_path/settings.xml";

our $specs = {};

memoize('frame_info', LIST_CACHE => MERGE);

sub new {
   my $class = shift;
   my $this  = [qw(pre)]; # you have to be the types of things you hook

   return bless $this, $class;
}

# this is basically here just to load the settings.xml file
sub pre {
   my ($this, $opts, $map, $groups) = @_;

   $opts->{_the_queue} ||= Games::RolePlay::MapGen::MapQueue->new({_the_map => $map});

   my $xp = XML::Parser->new(
      Handlers => {
         Init  => sub {
            my $expat = shift;
            $expat->{Tree}         = {};
            $expat->{Tree}{ByNum}  = {};
            $expat->{Tree}{ByName} = {};
            $expat->{LastTile}     = {};
         },
         Start => sub {
            my ($expat, $tag, $hash) = (shift, shift, { @_ });
            return unless (scalar keys %$hash);

            my ($name, $num) = map { $hash->{$_} } qw(name num);
            ($hash->{$_} = 0 if ($hash->{$_} eq 'false')) for keys %$hash;  # convert booleans
            $hash->{type} = lc($tag);

            my $fname = $name;
            if    ($hash->{type} eq 'tile' && $hash->{isFramed}) {
               $hash->{frames} = [];
               $expat->{LastTile} = $hash;
            }
            elsif ($hash->{type} eq 'frame') {
               $hash->{tile} = $expat->{LastTile};
               push(@{$expat->{LastTile}{frames}}, $hash);

               # produce full name from name/variety/dir
               $fname = $hash->{name}    || $hash->{tile}{name};
               my $v  = $hash->{variety} || $hash->{tile}{variety};
               my $d  = $hash->{dir}     || $hash->{tile}{dir};
               $fname .= $v ? "-$v" : '';
               $fname .= $d ? "-$d" : '';
            }

            if ($fname) {
               $expat->{Tree}{$tag}{$fname}       = $hash;
               $expat->{Tree}{ByName}{$fname}     = $hash;
            }
            if (defined $num) {
               $expat->{Tree}{ByNum}{$tag} ||= [];
               $expat->{Tree}{ByNum}{$tag}[$num] = $hash;
            }
         },
         End   => sub { return undef; },
         Char  => sub { return undef; },
         Final => sub { (shift)->{Tree}; },
      }
   );
   $specs = $xp->parsefile($opts->{'terraria_settings_xml'});
}

sub odds_pick {
   my ($arr) = (@_);

   my $loop = 0;
   while (++$loop < 1000) {  # keep doing this until we get something (within reason)
      ### TODO: Really should convert this to use GRM::Tools::str_eval ###
      for (@$arr) { return $$_[0] if (rand() <= $$_[1]); }
   }

   return undef;
}

sub add_to_tile {
   my ($t, $mq, $item, $allowed, $attr) = @_;
   return 0 unless ($t && $mq && $item && $allowed);
   return 0 unless ($specs->{ByName}{$item});

   # Liquid = on GRPMG::Tile object
   if    ($allowed =~ /liquid/ && $item =~ /Water|Lava/) {
      $t->{liquid} = $specs->{GlobalColor}{$item};
      $t->{liquid_percent} = $attr->{amount_per};
      return 1;
   }
   # Wall = on GRPMG::Tile object
   elsif ($allowed =~ /wall/   && $specs->{Wall}{$item}) {
      $t->{bg_wall} = $specs->{Wall}{$item};
      return 1;
   }
   # Tile = as a new MapQueue object
   elsif ($allowed =~ /tile/   && ($specs->{Frame}{$item} || $specs->{Tile}{$item})) {
      my $obj = new Games::RolePlay::MapGen::MapQueue::Object("Tile: $item");
      $obj->nonunique;
      map { $obj->attr($_ => $attr->{$_}); } keys %$attr if ($attr);
      $obj->attr('ref' => ($specs->{Frame}{$item} || $specs->{Tile}{$item}));
      $mq->add($obj => ($t->{x}, $t->{y}));
      return 1;
   }
   # Item = as a new MapQueue object
   elsif ($allowed =~ /item/   && $specs->{Item}{$item}) {
      my $obj = new Games::RolePlay::MapGen::MapQueue::Object("Item: $item");
      $obj->nonunique;
      map { $obj->attr($_ => $attr->{$_}); } keys %$attr if ($attr);
      $obj->attr('ref' => $specs->{Item}{$item});
      $mq->add($obj => ($t->{x}, $t->{y}));
      return 1;
   }

   return 0;
}

sub frame_info {
   my ($f) = @_;
   my $frm = $f;

   $frm = $specs->{Frame}{$f} || $specs->{Tile}{$f} || $specs->{ByName}{$f} unless (ref $f);
   return undef unless (ref $f);

   my %hash = @$frm;
   if    ($frm->{type} eq 'tile') {
      $hash{size}      = '1,1';
      $hash{upperLeft} = '0,0';
   }
   elsif ($frm->{type} eq 'frame') {
      $hash{$_} ||= $hash{tile}->{$_} for (qw(color name isSolid size placement isSolidTop growsOn hangsOn canMixFrames isHouseItem lightBrightness contactDmg));

      # produce full name from name/variety/dir
      $fname = $hash{name};
      my $v  = $hash{variety};
      my $d  = $hash{dir};
      $fname .= $v ? "-$v" : '';
      $fname .= $d ? "-$d" : '';
      $hash{fname} = $fname;
   }

   return \%hash;
}

##############################################################################
# GRPMG::Tiles to Terraria tiles (a rather large sub)

sub tile_convert {
   my ($mo) = @_;
   my ($map, $mq, $groups) = map { $mo->{_the_$_} } qw(map queue groups);
   my $tmap = {
      liquid => [][],
      wall   => [][],
      block  => [][],
   };

   my $door_tile = {
      'open' => {
         n => $specs->{Tile}{"Wooden Platform"},  # no such thing as an "open" platform
         s => $specs->{Tile}{"Wooden Platform"},
         w => $specs->{Tile}{"Door Open-l"},
         e => $specs->{Tile}{"Door Open-r"},
      }
      'closed' => {
         n => $specs->{Tile}{"Wooden Platform"},
         s => $specs->{Tile}{"Wooden Platform"},
         w => $specs->{Tile}{"Door Closed"},
         e => $specs->{Tile}{"Door Closed"},
      }
   };
   $door_tile->{$_} = $door_tile->{closed} for qw(secret stuck locked);  # can't really do anything different here, either

   # walk through each GRPMG tile
   foreach my $y (0 .. $#$map) {
      my $xend = $#{$map->[$y]};

      foreach my $x (0 .. $xend) {
         my $t  = $map->[$y][$x];
         my $xp = $x  * $mo->{x_size};     # min x
         my $yp = $y  * $mo->{y_size};     # min y
         my $Xp = $xp + $mo->{x_size} - 1; # max x; account for zero-based X/Y
         my $Yp = $yp + $mo->{y_size} - 1; # max y; account for zero-based X/Y
         my $empty_dir = $t->{type} ? join('', grep { $t->{od}{$_} == 1 } qw(n s w e)) : '';  # == 1 doesn't match doors...
         my $wall_dir  = $t->{type} ? join('', grep { $t->{od}{$_} == 0 } qw(n s w e)) : '';  # == 0 doesn't match doors...

         # wall/door lines (with corrections for corners)
         my $dir_line = {
            'n' => [ $xp+1, $yp   => $Xp-1, $yp   ],
            'w' => [ $xp,   $yp+1 => $xp,   $Yp-1 ],
            'e' => [ $Xp,   $yp+1 => $Xp,   $Yp-1 ],
            's' => [ $xp+1, $Yp   => $Xp-1, $Yp   ],
         };
         my $dir_line_door_space = {  # needed since (some) doors aren't two-pixels thick (actually enters the previous GRPMG tile)
            'n' => [ $xp+1, $yp-1 => $Xp-1, $yp-1 ],
            'w' => [ $xp-1, $yp+1 => $xp-1, $Yp-1 ],
            'e' => [ $Xp+1, $yp+1 => $Xp+1, $Yp-1 ],
            's' => [ $xp+1, $Yp+1 => $Xp-1, $Yp+1 ],
         };
         my $dir_line_wall_space = {  # things on walls
            'n' => [ $xp+1, $yp+1 => $Xp-1, $yp+1 ],
            'w' => [ $xp+1, $yp+1 => $xp+1, $Yp-1 ],
            'e' => [ $Xp-1, $yp+1 => $Xp-1, $Yp-1 ],
            's' => [ $xp+1, $Yp-1 => $Xp-1, $Yp-1 ],
         };

         # corner points
         my $corners = {
            'nw' => [ $xp, $yp ],
            'ne' => [ $Xp, $yp ],
            'sw' => [ $xp, $Yp ],
            'se' => [ $Xp, $Yp ],
         };

         $mo->{t_cb}->() if exists $mo->{t_cb};

         # Walls, BG Walls, and corners
         if ($t->{type}) {  # empty space
            ### FIXME: main parameters needs a "wall tile" option ###
            ### FIXME: make sure bg_wall is added in as well ###
            tile_rect($tmap, $xp, $yp => $Xp, $Yp, wall  => $t->{bg_wall});
            tile_rect($tmap, $xp, $yp => $Xp, $Yp, block => $t->{wall});
            foreach my $dir qw(n w e s) {
               tile_line($tmap, @{$dir_line->{$dir}}, block => undef) if ($empty_dir =~ /$dir/);
            }
            ### FIXME: Check all four spokes of corner to see if the corner is isolated ###
            foreach my $pt qw(nw ne sw se) {
               my ($fd, $sd) = split(//, $pt);
               tile_pixel($tmap, @{$corners->{$pt}}, block => undef) if ($empty_dir =~ /$fd.*$sd/);
            }
         }
         else {             # complete wall
            tile_filled_rect($tmap, $xp, $yp => $Xp, $Yp, block => $t->{wall});
            next;
         }
         
         # Liquid
         if ($t->{liquid}) {
            # figure out the fill amount (fortunately, the liquid layer is all by itself, so this is easy)
            my $tiles = ($t->{liquid_percent} || 100) / 100 * $mo->{x_size} * $mo->{y_size};
            my $lines = int($tiles / $mo->{x_size});
            my $tmod  = $tiles - $lines;
            
            if ($lines) {
               my @xy  = @{$corners->{sw}} => @{$corners->{se}};
               $xy[1] -= $lines - 1;  # elevate the Y-axis
               tile_filled_rect($tmap, @xy, liquid => $t->{liquid});
               
               if ($tmod) {
                  $xy[3] = ++$xy[1];        # y = next row and single line
                  $xy[2] = $xy[0] + $tmod;  # x = start + reminder
                  tile_line($tmap, @xy, liquid => $t->{liquid});
               }
            }
         }

         # Doors         
         foreach my $dir (qw(n w)) {  # NOTE: we never need to draw s and e doors, that just duplicates efforts
            if (ref($t->{od}{$dir})) {
               if ($t->{nb}{$dir} && $t->{nb}{$dir}{type} eq 'room') {  # needs to go on the closest tile to the room
                  my $opp = $Games::RolePlay::MapGen::opp{$dir};  # use opposite door
                  
                  tile_line($tmap, @{$dir_line_door_space->{$dir}}, block => $door_tile{$opp});  # using the room's tile's opposite direction for the door
                  tile_line($tmap, @{$dir_line->{$dir}},            block => undef);
               }
               else {
                  tile_line($tmap, @{$dir_line_door_space->{$dir}}, block => undef);
                  tile_line($tmap, @{$dir_line->{$dir}},            block => $door_tile{$dir});
               }
            }
         }

         ### FIXME: Make sure objects don't bump into each other (if possible) ###
         
         # Check for objects
         next unless ($mq);
         # this sort works out: undef/any is first, and surface is last
         # (oh and thank Perl we have Memoize for frame_info...)
         foreach my $obj (sort { frame_info($a)->{placement} cmp frame_info($b)->{placement} } $mq->objs_at_location($x, $y)) {
            my $tag = uc($obj->{v});
            my $frm = frame_info($obj->attr('ref'));
            next unless ($frm->{type} =~ /^(tile|frame)$/);  # items need to go in chests
            ### FIXME: Support for NPCs, chests, and signs ###

            ### TODO: Support for growsOn hangsOn ###
            my @dirs;
            given ($frm->{placement}) {
               when (/wall/i)    { push(@dirs, qw(w e)); continue; }
               when (/ceiling/i) { push(@dirs, 'n');     continue; }
               when (/floor/i)   { push(@dirs, 's');     continue; }
               when (/surface/i) { push(@dirs, 'S');     continue; }
               when (/CFBoth/)   { warn "CFBoth objects (besides doors) not supported yet!"; next; }
               default {  # any
                  @dirs = ('A');  # special case; not affected by gravity
               }
            }
            @dirs = shuffle(@dirs);
         
            ### TODO: Support for isSolid isSolidTop ###
            my ($w, $h) = split(/\s*,\s*/, $frm->{size} || '1,1');
            foreach my $dir (@dirs) {
               given ($dir) {
                  when ('A') {            # 'any' block; scattered pattern along the empty space
                     # no such thing as an 'any' block with a size greater than 1x1, so we aren't doing that check
                     ### FIXME: Use amount_per attr here ###
                     
                     # main space
                     foreach my $yy (($yp+1) .. ($Yp-1)) {
                        foreach my $xx (($xp+1) .. ($Xp-1)) {
                           # (a little wasteful using tile_pixel, but it's kinda hard to detail an abstract shape any other way)
                           tile_pixel($tmap, $xx, $yy, block => $frm) if (random(2));  
                        }
                     }

                     # doorway spaces
                     foreach my $dir qw(n w e s) {
                        if ($empty_dir =~ /$dir/) {
                           my ($sx, $sy, $ex, $ey) = @{$dir_line->{$dir}};
                           foreach my $yy ($sy .. $ey) {
                              foreach my $xx ($sx .. $ex) {
                                 tile_pixel($tmap, $xx, $yy, block => $frm) if (random(2));
                              }
                           }
                        }
                     }
                     
                     ### TODO: Corners ###
                     last;
                  }
                  when (/[news]/) {
                     next unless ($wall_dir =~ /$dir/);
                     
                     my ($sx, $sy, $ex, $ey) = @{$dir_line_wall_space->{$dir}};
                     
                     ### FIXME: Use amount_per attr here; might need multiple $dir ###
                     ### FIXME: What to do about objects bigger than the mini 3x3 space we have? ###
                     ### FIXME: If no floor space, these objects can still be put on a block ###

                     # make sure it fits
                     if ($dir =~ /[ns]/) { $sx += $w - 1; $ex -= $w - 1; }
                     else                { $sy += $h - 1; $ey -= $h - 1; }
                     
                     my $xx = choice($sx .. $ex);
                     my $yy = choice($sy .. $ey);
                     tile_pixel($tmap, $xx, $yy, block => $frm);
                     last;
                  }
                  when (/S/) {
                     ### FIXME: Need object detection/records first ###
                     next;
                  }
               }
            }

            ### FIXME: Check to see if object was actually placed ###
            
            
         }
      }
   }

   return $tmap;
}

sub tile_pixel {
   my ($tmap, $x, $y, $layer, $obj);
   return $tmap->{$layer}[$x][$y] = undef unless (defined $obj);
   
   my $frm = frame_info($obj);
   my $type = $frm->{type};
   
   given ($type) {
      when ('globalcolors') {  # this better be a real liquid...
         ### TODO: Terraria supports water levels on individual tiles ###
         return $tmap->{liquid}[$x][$y] = $obj;
      }
      when ('wall') {
         return $tmap->{wall}[$x][$y] = $obj;
      }
      when (/^(tile|frame)$/) {
         # this is the bigger deal to tackle...
         state $frm_cache = {};  # (all standard 1x1 objects have refs to the same object; frames need a cache, 
                                 #  so that they are pointing to the same ref, and not eating up a ton of RAM)
         my $frm_obj;
         my $fttl = $frm->{frames} ? scalar @{$frm->{frames}} : 0;

         if ($type eq 'tile')  {  # let's hope that it's a single frame
            unless ($fttl)                  { $frm_obj = $frm; }  # usually from a single default frame
            elsif  (!$frm->{canMixFrames})  {                     # just going to have to spin the wheel here...
               ### TODO: Place objects in l/r direction depending on w/e walls ###
               
               $frm = frame_info(choice(@{$frm->{frames}}));
               $type = 'frame';
            }
         }

         my ($sx, $sy) = split(/\s*,\s*/, $frm->{size} || '1,1');
         
         if ($sx == 1 && $sy == 1) {
            # Just a single pixel, no worries
            return $tmap->{block}[$x][$y] = $obj;
         }
         die "Multi-tiled object without isFramed set, against XML specs!" unless ($type eq 'frame' || $frm->{isFramed});
         
         my @rnd_str = map { random($fttl) } (0 .. $sx*$sy-1) if ($frm->{canMixFrames});
         my $fname = $frm->{fname} || $frm->{name};
         $frm_obj = $frm_cache->{$fname} || ($frm_cache->{$fname} = $frm);
         my ($ux, $uy) = split(/\s*,\s*/, $frm->{upperLeft} || '0,0');

         # FYI, $_[xy]: s = size, o = offset, t = tile, u = upperLeft
         foreach my $ox (0 .. $sx-1) {
            foreach my $oy (0 .. $sy-1) {
               ($ux, $uy) = split(/\s*,\s*/, $frm->{frames}[shift @rnd_str]->{upperLeft} || die "Frame without upperLeft co-ordinates, against XML specs!")) if ($frm->{canMixFrames});
               my ($fx, $fy) = ($ux + $ox * 18, $uy + $oy * 18);  # skip by 18 frame points
               my ($tx, $ty) = ($x+$ox, $y+$ty);

               $frm_obj->{frame_xy}[$tx][$ty] = "$fx,$fy";  # (this also saves on memory, since the hash doesn't get warped while putting XY in there.)
               $tmap->{block}[$tx][$ty] = $frm_obj;
            }
         }
         
         return $frm_obj;
      }
      when ('item') {
         die "Found an illegal item object (".$frm->{name}.") on pixel ($x, $y)!";
      }
      when ([undef, '', /^\s+$/]) {
         die "Found an undefined object (".$frm->{name}.") on pixel ($x, $y)!";
      }
      default {
         die "Found an illegal $type object (".$frm->{name}.") on pixel ($x, $y)!";
      }
   }
   
   die "???  What's more default than default?!  (Perl broken)";
}

sub tile_line = \&tile_filled_rect;  # we aren't doing diagonal lines, anyway

sub tile_rect {
   my ($tmap, $x1, $y1, $x2, $y2, $layer, $obj);
   
   # Check for large objects
   if ($obj) {
      my $frm = frame_info($obj);
      if ($frm->{size} && $frm->{size} !~ /^\s*1\s*,\s*1\s*$/) { return tile_pixel($tmap, $x1, $y1, $layer, $obj); }
   }   
   
   foreach my $xyarg ([$x1, $y1, $x1, $y2],
                      [$x1, $y1, $x2, $y1],
                      [$x2, $y1, $x2, $y2],
                      [$x1, $y2, $x2, $y2])
   { tile_line($tmap, @$xyarg, $layer, $obj); }
   return $obj;
}

sub tile_filled_rect {
   my ($tmap, $x1, $y1, $x2, $y2, $layer, $obj);

   # Check for large objects
   if ($obj) {
      my $frm = frame_info($obj);
      if ($frm->{size} && $frm->{size} !~ /^\s*1\s*,\s*1\s*$/) { return tile_pixel($tmap, $x1, $y1, $layer, $obj); }
   }

   for my $x ($x1 .. $x2) {
      for my $y ($y1 .. $y2) { $tmap->{$layer}[$x][$y] = $obj; }
   }

   return $obj;
}


1;

__END__

=head1 NAME

Games::RolePlay::MapGen::GeneratorPlugin::Terraria - Initialization for other Terraria plug-ins

=head1 SYNOPSIS

   use Games::RolePlay::MapGen

   my $map = new Games::RolePlay::MapGen;
   $map->add_generator_plugin("Terraria");

=head1 DESCRIPTION

This module doesn't actually do anything to the map, but it's required for the other Terraria
plug-in modules.  It loads the settings.xml file for those other plug-in modules, as well as a few
other things.

The default XML file included is usually fine, but if you happen to have an updated version, the
C<terraria_settings_xml> setting will change the path of the filename.  (By the way, the file is from
L<BinaryConstruct's TEdit|https://github.com/BinaryConstruct/Terraria-Map-Editor/blob/master/TEdit/settings.xml>,
if you want to double-check for updates.)

=head1 SEE ALSO

Games::RolePlay::MapGen

=head1 AUTHOR

Brendan Byrd <PerlMod@ResonatorSoft.org>

=cut
