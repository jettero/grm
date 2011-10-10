package Games::RolePlay::MapGen::GeneratorPlugin::Terraria::NPCs;

use v5.10;
use strict;
use Games::RolePlay::MapGen::GeneratorPlugin::Terraria qw( odds_pick add_to_tile );
use Games::RolePlay::MapGen::Tools qw( irange );

##############################################################################

$Games::RolePlay::MapGen::known_opts{'terraria_npc_room_odds'} = [
   # NPC,     Odds
   [undef,    .40],
   [Guide,    .50],
   [Merchant, .10],
];

our $specs = {};
*specs = *Games::RolePlay::MapGen::GeneratorPlugin::Terraria::specs{SCALAR};

sub new {
   my $class = shift;
   my $this  = [qw(trap)]; # you have to be the types of things you hook

   return bless $this, $class;
}

sub trapgen {
   my ($this, $opts, $map, $groups) = @_;
   my $mq = $opts->{_the_queue};
   return undef unless ($mq && scalar keys %$specs);
   
   # Corridor checks
   if (scalar @{$opts->{'terraria_trap_corr_obj_odds'}}) {
      foreach my $loc ($mq->all_open_locations) {
         my ($x, $y) = @$loc;
         my $t = $map->[$y][$x];
         next unless ($t->{type} eq 'corridor');
         add_to_tile($t, $mq, odds_pick($opts->{'terraria_trap_corr_obj_odds'}), 'liquid tile');
      }
   }

   if (scalar @{$opts->{'terraria_trap_room_obj_odds'}}) {
      foreach my $grp (@$groups) {
         next unless ($grp->{type} eq 'room');
         
         my $item = odds_pick($opts->{'terraria_trap_room_obj_odds'});
         next unless ($specs->{ByName}{$item});
         
         my %attr;
         given ($item) {
            when ('Spikes') {
               $attr{placement} = 'floor_line';
            }
            when (/Sand|Water|Lava/) {
               $attr{placement} = 'full_block';
            }
            default {
               my $p = $specs->{Tile}{$item};
               if ($p && $p->{isSolid} && !$p->{isFramed}) { $attr{placement} = 'full_block'; }
               else                                        { $attr{placement} = 'floor'; }
            }
         }
         
         ### TODO: Support for irregular rooms ###
         my @e = @{$grp->{extents}};

         # either take up multiple y-axis or just the bottom row
         my $ys = ($attr{placement} eq 'full_block') ? irange($e[1], $e[3]) : $e[3];
         foreach my $y ($ys .. $e[3]) {
            
            # either take up one cell or the entire x-axis
            my @x = ($attr{placement} eq 'floor') ? (irange($e[0], $e[2])) : ($e[0] .. $e[2]);
            foreach my $x (@x) {
               add_to_tile($map->[$y][$x], $mq, $item, 'liquid tile', \%attr);
            }
         }
      }
   }
}


1;

__END__

=head1 NAME

Games::RolePlay::MapGen::GeneratorPlugin::Terraria::NPCs - NPCs plug-in for Terraria maps

=head1 SYNOPSIS

   use Games::RolePlay::MapGen;

   my $map = new Games::RolePlay::MapGen;
   $map->add_generator_plugin("Terraria");
   $map->add_generator_plugin("Terraria::NPCs");
   $map->generate(
      terraria_npc_room_odds => [
         # Object, Odds
         [undef,    .40],
         [Guide,    .50],
         [Merchant, .10],
      ],
   );

=head1 DESCRIPTION

This module adds NPCs to Terraria maps.  The above example are the defaults, but you can change them to any
odds array set of NPC objects.  NPC rooms will be automatically marked as such, so that the room is built with
the right walls.  Also, the other house requirements are automatically added:

   Is completely enclosed in Blocks (aside from the entrance) to serve as side walls, a floor, and a ceiling.
   Has at least 1 placed Comfort item.  (Random)
   Has at least 1 placed Flat Surface item.  (Random)
   Has at least 1 entrance, which can be a Wooden Door in a wall or a Wood Platform in the ceiling or floor.
   Has at least 1 light source. A Furnace or Lamp Post will not work for this purpose.
   Is at least 5 blocks tall and 7 blocks wide (or 4 blocks tall and 8 blocks wide, not including walls, floor or ceiling). 
   
The Comfort item and Flat Surface item will be added in the room, close to the NPC.  If the BasicDoors plug-in
is added, this will cover the doors.  Otherwise, they are completely filled in, to make it enclosed.  The size
is typically naturally set, since a default tile size of 5x5 will only require a room that is 2x2 tiles big to
met the requirements.  If not, the room is skipped for consideration.  Also, trap rooms are skipped, as that
might be a nasty combination.

=head1 NPCs

The correct names to use for all of the NPCs are:

   Guide
   Merchant
   Nurse
   Demolitionist
   ArmsDealer
   Dryad
   OldMan
   Clothier

=head1 Object/Odds ArrayREFs

The two variables above expect an ARRAY of ARRAYs, with each inner array containing the object name (or undef) and
the odds of it occurring on that block, as decimal percentage.  The odds picker will first roll the odds of the
first item.  If it hit, that item "won".  If not, it moves to the next item.  This repeats on all of the items until
it wins the odds on one of them.  If the end of the array is reached with nothing won, the process will restart at
the beginning of the array.

This standard odds picker is used for all of the Terraria plug-ins.

=head1 SEE ALSO

Games::RolePlay::MapGen

=head1 AUTHOR

Brendan Byrd <PerlMod@ResonatorSoft.org>

=cut
