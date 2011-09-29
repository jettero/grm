package Games::RolePlay::MapGen::Exporter::TerrariaPNG;
use v5.10;
use Data::Dumper;
use List::Util qw(shuffle);
use Games::RolePlay::MapGen::GeneratorPlugin::Terraria;
use Games::RolePlay::MapGen::MapQueue;
use parent qw(Games::RolePlay::MapGen::Exporter::PNG);

sub genmap {
   my $this = shift;
   my $opts = shift;
   my $mq   = $opts->{map_queue};
   my $map  = $opts->{_the_map};

   $this->gen_cell_size($opts);

   my $gd = new GD::Image($opts->{x_size} * @{$map->[0]}, $opts->{y_size} * @$map, 1);  # World Creator doesn't support indexed PNG
   $gd->alphaBlending(0);
   $gd->transparent(-1);
   
   my ($terraria_obj, $map_opts, $wall_objs) = Games::RolePlay::MapGen::GeneratorPlugin::Terraria::import();

   my $empty_color = $gd->colorAllocate(@{$terraria_obj->{WALL_BACKGROUND}{color}});
   my $wall_color  = $gd->colorAllocate(@{$terraria_obj->{DUNGEON_BLUE}{color}});
   my %door_color;
   $door_color{n} = $gd->colorAllocate(@{$terraria_obj->{WOODP}{color}});
   $door_color{w} = $gd->colorAllocate(@{$terraria_obj->{DOOR1}{color}});
   my %obj_color;
   
   $gd->filledRectangle(0, 0 => $opts->{x_size} * @{$map->[0]}, $opts->{y_size} * @$map, $empty_color);  # just to make sure we start off with empty space

   foreach my $y (0 .. $#$map) {
      my $xend = $#{$map->[$y]};

      foreach my $x (0 .. $xend) {
         my $t  = $map->[$y][$x];
         my $xp = $x  * $opts->{x_size};     # min x
         my $yp = $y  * $opts->{y_size};     # min y
         my $Xp = $xp + $opts->{x_size} - 1; # max x; account for zero-based X/Y
         my $Yp = $yp + $opts->{y_size} - 1; # max y; account for zero-based X/Y
         my $empty_dir = $t->{type} ? join('', grep { $t->{od}{$_} == 1 } qw(n s w e)) : '';  # == 1 doesn't match doors...

         # wall/door lines (with corrections for corners)
         my $dir_line = {
            'n' => [ $xp+1, $yp   => $Xp-1, $yp   ],
            'w' => [ $xp,   $yp+1 => $xp,   $Yp-1 ],
            'e' => [ $Xp,   $yp+1 => $Xp,   $Yp-1 ],
            's' => [ $xp+1, $Yp   => $Xp-1, $Yp   ],
         };
         my $dir_line_door_space = {  # needed since doors aren't two-pixels thick
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

         $opts->{t_cb}->() if exists $opts->{t_cb};

         if ($t->{type}) {  # empty space
            $gd->rectangle($xp, $yp => $Xp, $Yp, $wall_color);
            foreach my $dir qw(n w e s) {
               $gd->line(@{$dir_line->{$dir}}, $empty_color) if ($empty_dir =~ /$dir/);
            }
            ### FIXME: Check all four spokes of corner to see if the corner is isolated ###
            foreach my $pt qw(nw ne sw se) {
               my ($fd, $sd) = split(//, $pt);
               $gd->setPixel(@{$corners->{$pt}}, $empty_color) if ($empty_dir =~ /$fd.*$sd/);
            }
         }
         else {             # complete wall
            $gd->filledRectangle($xp, $yp => $Xp, $Yp, $wall_color);
            next;
         }

         # NOTE: we never need to draw s and e doors, that just duplicates efforts
         foreach my $dir (qw(n w)) {
            ### FIXME: Check for rooms to see which side the door should go on ###
            if (ref($t->{od}{$dir})) {
               $gd->line(@{$dir_line->{$dir}},            $door_color{$dir});
               $gd->line(@{$dir_line_door_space->{$dir}}, $empty_color);
            }
         }

         # Check for objects
         next unless ($mq);
         foreach my $obj ($mq->objs_at_location($x, $y)) {
            my $tag   = uc($obj->{v});
            my $color = $obj_color{$tag} ||= $gd->colorAllocate(@{$terraria_obj->{$tag}{color}});

            ### FIXME: Assuming placement of item is already near wall, etc.
            my @dirs;
            given ($terraria_obj->{$tag}{type}) {
               when (/^wall/) {  # random wall
                  @dirs = shuffle qw(n w e s);
               }
               when (/^ceiling/) {
                  @dirs = ('n');
               }
               default {  # floor
                  @dirs = ('s');
               }
            }

            given ($terraria_obj->{$tag}{type}) {
               when ('block') {                  # scattered pattern along the empty space
                  # main space
                  foreach my $yy (($yp+1) .. ($Yp-1)) {
                     foreach my $xx (($xp+1) .. ($Xp-1)) {
                        $gd->setPixel($xx, $yy, $color) if (rand() <= .5);
                     }
                  }

                  # doorway spaces
                  foreach my $dir qw(n w e s) {
                     if ($empty_dir =~ /$dir/) {
                        my ($sx, $sy, $ex, $ey) = @{$dir_line->{$dir}};
                        foreach my $yy ($sy .. $ey) {
                           foreach my $xx ($sx .. $ex) {
                              $gd->setPixel($xx, $yy, $color) if (rand() <= .5);
                           }
                        }
                     }
                  }
               }
               when ('liquid') {                 # totally filled
                  $gd->filledRectangle($xp+1, $yp+1 => $Xp-1, $Yp-1, $color);
                  foreach my $dir qw(n w e s) {
                     $gd->line(@{$dir_line->{$dir}}, $color) if ($empty_dir =~ /$dir/);
                  }
               }
               when (/door|platform/) {          # shouldn't even get this
                  next;
               }
               when (/item$|light$|special$/) {  # on random location in floor/ceiling or random wall
                  foreach my $dir (@dirs) {
                     unless ($t->{od}{$dir}) {
                        my ($sx, $sy, $ex, $ey) = @{$dir_line_wall_space->{$dir}};
                        my ($xx, $yy) = (int(rand($ex - $sx) + $sx), int(rand($ey - $sy) + $sy));
                        $gd->setPixel($xx, $yy, $color);
                        last;
                     }
                  }
               }
               when ('room_item') {              # build a proper walled-off room around item
                  ### TODO ###
               }
               when (/trap$/) {                  # on all locations in floor/ceiling or random wall
                  foreach my $dir (@dirs) {
                     unless ($t->{od}{$dir}) {
                        $gd->line(@{$dir_line_wall_space->{$dir}}, $color);
                        last;
                     }
                  }
               }
               when ('plants') {                 # placed on special soil
                  ### TODO ###
               }
               when ('chest') {                  # contains special items
                  ### TODO ###
               }
               when ('sign') {                   # contains message
                  ### TODO ###
               }
               when ('wall') {                   # goes on special wall image
                  ### TODO ###
               }
            }
         }
      }
   }

   return $gd;
}

1;