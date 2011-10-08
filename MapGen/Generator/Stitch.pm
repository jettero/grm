package Games::RolePlay::MapGen::Generator::Stitch;

use strict;
use Carp;
use parent qw(Games::RolePlay::MapGen::Generator::Blank);
use Games::RolePlay::MapGen::Tools qw( _group _tile _door );

sub genmap {
    my $this = shift;
    my $opts = shift;

    my @map    = $this->create_tiles( $opts );
    my $map    = new Games::RolePlay::MapGen::_interconnected_map(\@map);
    my $groups = [];

    for my $i ( 0 .. $#{$opts->{map_input}} ) {
       my $smap_obj = $opts->{map_input}[$i];
       my $smap     = $smap_obj->{_the_map};

       ### FIXME: Change Stitch options to hash of array of hashes, starting with 'stitch_input' => [ {} ]
       my $xl = $opts->{upper_left}[$i][0];
       my $yl = $opts->{upper_left}[$i][1];
       my $xo = ($opts->{upper_left_submap} && $opts->{upper_left_submap}[$i]) ? ($opts->{upper_left_submap}[$i][0] ||                   0) : 0;
       my $yo = ($opts->{upper_left_submap} && $opts->{upper_left_submap}[$i]) ? ($opts->{upper_left_submap}[$i][1] ||                   0) : 0;
       my $xs = ($opts->{size}              && $opts->{size}[$i])              ? ($opts->{size}[$i][0]              || $smap_obj->{x_size}) : $smap_obj->{x_size};
       my $ys = ($opts->{size}              && $opts->{size}[$i])              ? ($opts->{size}[$i][1]              || $smap_obj->{y_size}) : $smap_obj->{y_size};

       ### FIXME: This should be the same for all maps, or error ##
       $opts->{$_} = $opts->{map_input}[$i]{$_} for qw(tile_size cell_size);

       ### TODO: Remove 'fog' tiles from actual 'SubMap' objects ###
       
       for my $x2 ( $xl .. ($xl+$xs-1) ) { my $x1 = $x2-$xl+$xo;
       for my $y2 ( $yl .. ($yl+$ys-1) ) { my $y1 = $y2-$yl+$yo;
           my $otile = $smap->[ $y1 ][ $x1 ];

           my $ntile = $map->[ $y2 ][ $x2 ] = &_tile( x=>$x2, y=>$y2, (exists $otile->{type} ? (type=>$otile->{type}) :()) );
           for my $d (qw(n e s w)) {
               my $ood = $otile->{od}{$d};

               my @ops = ($x2,$y2);
                  $ops[0] ++ if $d eq "e";
                  $ops[0] -- if $d eq "w";
                  $ops[1] ++ if $d eq "s";
                  $ops[1] -- if $d eq "n";
               
               # out of bounds
               if ($ops[0] >= $opts->{x_size} || $ops[1] >= $opts->{y_size}) {
                   $ntile->{od}{$d} = 0;
                   next;
               }

               my $opp = $Games::RolePlay::MapGen::opp{$d};
               if( my $nt = $map->[ $ops[1] ][ $ops[0] ] ) {
                   if( ref $ood ) {
                       $nt->{od}{$opp} = $ntile->{od}{$d} = &_door(
                           map {($_ => $ood->{$_})} qw(locked stuck secret open),
                           open_dir => { map {($ood->{open_dir}{$_})} qw(major minor) },
                       );

                   } elsif($ood) {
                       $nt->{od}{$opp} = $ntile->{od}{$d} = 1;
                   }
               }
           }
       }}

       # Add entire submap as a group
       my $sgroup = &_group( type => 'submap' );
       $sgroup->add_rectangle([$xl, $yl], [$xs, $ys]);
       push(@$groups, $sgroup);

       # Port over other groups
       for my $ogroup ( @{$smap_obj->{_the_groups}} ) {
           my $ngroup = &_group( exists $ogroup->{type} ? (type => $ogroup->{type}) : () );
           
           for my $l ( 0 .. $#{$ogroup->{loc}} ) {
               my ($gxl, $gyl, $gxs, $gys) = map { @{$ogroup->{$_}[$l]} } qw(loc size);
               my ($gxm, $gym) = ($xo+$xs-$gxl, $yo+$ys-$gyl);  # lower-right max size
               next if ($gxl < $xo || $gyl < $yo);  # out of bounds
               $gxl += $xl-$xo;
               $gyl += $yl-$yo;
               $gxs = $gxm if ($gxs > $gxm);
               $gys = $gym if ($gys > $gym);
               
               $ngroup->add_rectangle([$gxl, $gyl], [$gxs, $gys], $map);
           }

           push(@$groups, $ngroup);
       }

       ### TODO: Port over the _the_queue object ###
    }

    $map = new Games::RolePlay::MapGen::_interconnected_map( $map );
     
    return ($map, $groups);
}

1;

__END__

=head1 NAME

Games::RolePlay::MapGen::Generator::Stitch - Stitch together smaller maps into a larger one (opposite of SubMap)

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $sub_map = new Games::RolePlay::MapGen;
       $sub_map->set_generator( "XMLImport" );
       $sub_map->generate( xml_input_file => "map.xml" );

    my $sub_map2 = new Games::RolePlay::MapGen;
       $sub_map2->set_generator( "XMLImport" );
       $sub_map2->generate( xml_input_file => "map2.xml" );

    my $map = new Games::RolePlay::MapGen;
       $map->set_generator( "Stitch" );
       $map->generate( map_input         => [$sub_map, $sub_map2],
                       upper_left        => [[0,0],       [0,10]],
                       upper_left_submap => [[],           [5,5]],
                       submap_size       => [[10,10],         []]);

This is essentially the opposite of SubMap, allowing you to combine submaps into a larger main map.
All parameters in C<generate()> must be arrayrefs, with each element referencing a different submap.  The submaps
coordinates will be extracted from C<upper_left_submap> and pasted into the C<upper_left> coordinates on the main
map, grabbing the size specified.  Both C<upper_left_submap> and C<size> are optional, defaulting to [0,0] and the
size of the submap, respectively.

The submaps will likely not be connected (especially with full copies), so some extra bit of code is required
to connect any pathways between them, if you so wish.

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut