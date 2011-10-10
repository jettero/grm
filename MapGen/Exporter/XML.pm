# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Exporter::XML;

use common::sense;
use Carp;
use Tie::IxHash;
use XML::Simple;

use parent qw(Games::RolePlay::MapGen::Exporter);

1;

# genmap {{{
sub genmap {
    my $this = shift;
    my $opts = shift;
    my $m    = $opts->{_the_map};
    my $g    = $opts->{_the_groups};

    my $options = [];
    my $groups  = [];
    my $map     = [];

    my $ah = sub { my %h; tie %h, "Tie::IxHash", (@_); \%h };

    my $i    = 0;
    my $oend = scalar(keys %$opts);
    my $gend = $#{ $opts->{_the_groups} };
    my $iend = $#{ $opts->{_the_map} };
    my $progress = Term::ProgressBar::Quiet->new({
        name   => 'Saving XML map',
        count  => $oend + $gend + $iend + 1,
        remove => 1,
        ETA    => 'linear',
    });
    $progress->minor(0);

    # options {{{
    my $sort_opts = sub {
        my ($c, $d) = map {ref $opts->{$_} ? 1:0} $a, $b;

        # warn "sorting ($a, $b, $c, $d)";

        return $c <=> $d if ($c + $d) == 1;
        return $a cmp $b;
    };

    for my $k (sort $sort_opts keys %$opts) {
        unless( $k =~ m/^(?:_.+?|objs|plugins)$/ ) {
            my $v = $opts->{$k};

            if( my $t = ref $v ) {
                next if $t ne "HASH"; # probably a r_cb => sub {} code ref from XMLImporter

                push @$options, $ah->( name=>$k, value=>join(" ", map { "$_: $v->{$_};" } sort keys %$v ));

            } else {
                push @$options, $ah->( name=>$k, value=>$v );
            }
        }
        $progress->update(++$i);
    }
    # }}}
    # groups {{{
    for my $g (@{ $opts->{_the_groups} }) {
        push @$groups, $ah->(
            name => $g->{name},
            type => $g->{type},
            rectangle => [map {
                $ah->(
                    loc  => join(",", @{ $g->{loc}[$_]  }),
                    size => join("x", @{ $g->{size}[$_] }),
                )
            } 0 .. $#{ $g->{loc} }],
        );
        $progress->update(++$i);
    }
    # }}}
    
    for my $i (0 .. $iend) {
        my $jend = $#{ $opts->{_the_map}[$i] };
        my $row  = $ah->( ypos=>$i, tile=>[] );

        for my $j (0 .. $jend) {
            my $tile = $opts->{_the_map}[$i][$j];

            my $h;
            if( my $t = $tile->{type} ) {
                my $closures = [];

                $h = $ah->(
                    xpos => $j,
                    type => $tile->{type},
                );

                for my $dir (qw(north south east west)) {
                    my $d = substr $dir, 0, 1;
                    my $o = $tile->{od}{$d};

                    if( $o == 1 ) {
                        # open -- so don't make it show a closure

                    } elsif( $o > 1 ) { 
                        my $door = $tile->{od}{$d};

                        push @$closures, $ah->( dir => $dir, type => "door", 
                            (map { $_ => $door->{$_} ? "yes" : "no" } qw(locked stuck secret open)),

                            (map { $_."_open_dir" => {n=>"north", e=>"east", s=>"south", w=>"west"}->{$door->{open_dir}{$_}} } qw(major minor)),
                        );

                    } else {
                        push @$closures, $ah->( dir => $dir, type => "wall" );
                    }
                }

                $h->{closure} = $closures if int @$closures;

                push @{ $row->{tile} }, $h;

            } else {
                push @{ $row->{tile} }, $h = {xpos=>$j, type=>"wall"}; # this didn't used to be here... it made parsing craptastic
            }

            $opts->{t_cb}->( ($j+1,$i+1), $h ) if exists $opts->{t_cb};
        }

        push @$map, $row if int @{$row->{tile}}
        $progress->update(++$i);
    }

    my %main; tie %main, "Tie::IxHash", (
        option     => $options,
        tile_group => $groups,
        'map'      => { row => $map },
    );
    $progress->update(++$i);

    return XMLout(\%main, 
        XMLDecl  => 
            "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n".
            "<!DOCTYPE MapGen SYSTEM \"MapGen.dtd\">\n".
            "<?xml-stylesheet type=\"text/xsl\" href=\"MapGen.xsl\"?>\n\n",
        RootName => "MapGen",
        NoSort   => 1, # IxHash does this, please don't help me, kthx
    );
}
# }}}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Exporter::XML - An xml MapGen exporter.

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
    
    $map->set_exporter( "XML" );

    generate  $map;
    export    $map( "filename.xml" );

=head1 DESCRIPTION

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
