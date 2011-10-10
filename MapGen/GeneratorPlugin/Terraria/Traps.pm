package Games::RolePlay::MapGen::GeneratorPlugin::Terraria::Traps;

use common::sense;  # works every time!
use Games::RolePlay::MapGen::GeneratorPlugin::Terraria qw( odds_pick add_to_tile frame_info );
use Games::RolePlay::MapGen::Tools qw( irange );

##############################################################################

$Games::RolePlay::MapGen::known_opts{'terraria_trap_room_obj_odds'} = [
   # Object, Odds
   [''     => .40],
   [Sand   => .20],
   [Water  => .20],
   [Spikes => .20],
   [Lava   => .20],
];
$Games::RolePlay::MapGen::known_opts{'terraria_trap_corr_obj_odds'} = [
   [''     => .98],
   [Sand   => .20],
   [Water  => .20],
   [Spikes =>   1]
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
   
   my ($i, $np) = (0, 0);
   my @open_loc = grep { my $loc = $_; $map->[$$loc[1]][$$loc[2]]->{type} eq 'corridor' } $mq->all_open_locations;
   my @room_grp = grep { $_->{type} eq 'room' } @$groups;
   my $max = (scalar @{$opts->{'terraria_trap_corr_obj_odds'}} ? scalar @open_loc : 0) +
             (scalar @{$opts->{'terraria_trap_room_obj_odds'}} ? scalar @room_grp : 0);
   my $progress = Term::ProgressBar::Quiet->new({
      name   => 'Adding traps',
      count  => $max + 1,
      remove => 1,
      ETA    => 'linear',
      max_update_rate => .1,
   });
   $progress->minor(0);

   # Corridor checks
   if (scalar @{$opts->{'terraria_trap_corr_obj_odds'}}) {
      foreach my $loc (@open_loc) {
         my ($x, $y) = @$loc;
         my $t = $map->[$y][$x];
         my %attr;
         $attr{amount_per} = 100;

         add_to_tile($t, $mq, odds_pick($opts->{'terraria_trap_corr_obj_odds'}), 'liquid tile', \%attr);
         $np = $progress->update($i) if (++$i >= $np);
      }
   }

   if (scalar @{$opts->{'terraria_trap_room_obj_odds'}}) {
      foreach my $grp (@room_grp) {
         $i++;
         my $item = odds_pick($opts->{'terraria_trap_room_obj_odds'});
         next unless (my $t = $specs->{ByName}{$item});
         
         my $fi = frame_info($item);
         my %attr;
         $attr{amount_per} = 100;
         my $p = $fi->{placement} || 'any';
         
         foreach my $xy ($grp->enumerate_tiles) {
            my ($x, $y) = @$xy;
            
            next unless ($p eq 'any' ||
                        ($p =~ /wall/i    && (!$map->[$y][$x]{od}{w} || !$map->[$y][$x]{od}{e})) ||
                        ($p =~ /floor/i   && !$map->[$y][$x]{od}{s}) ||
                        ($p =~ /ceiling/i && !$map->[$y][$x]{od}{n}));
            
            add_to_tile($map->[$y][$x], $mq, $item, 'liquid tile', \%attr);
         }
         $np = $progress->update($i) if ($i >= $np);
      }
   }
   $progress->update(++$i);
}


1;

__END__

=head1 NAME

Games::RolePlay::MapGen::GeneratorPlugin::Terraria::Traps - Trap plug-in for Terraria maps

=head1 SYNOPSIS

   use Games::RolePlay::MapGen;

   my $map = new Games::RolePlay::MapGen;
   $map->add_generator_plugin("Terraria");
   $map->add_generator_plugin("Terraria::Traps");
   $map->generate(
      terraria_trap_room_obj_odds => [
         # Object, Odds
         [undef,  .40],
         [Sand,   .20],
         [Water,  .20],
         [Spikes, .20],
         [Lava,   .20],
      ],
      terraria_trap_corr_obj_odds => [
         [undef,  .98],
         [Spikes,   1]
      ],
   );

=head1 DESCRIPTION

This module adds traps to Terraria maps.  The above example are the defaults, but you can change them to any
odds array set of liquid or tile objects.  Most traps will either fill up the room by a random amount, or in the
case of Spikes, will be aligned along the bottom of the floor.

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
