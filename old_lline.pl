=cut
sub _lline_of_sight {
    my $this = shift;
    my ($lhs, $rhs) = @_;

    return LOS_YES if "@$lhs" eq "@$rhs";

    my @lhs = (
        [ $lhs->[0]+0, $lhs->[1]+0 ], # sw corner
        [ $lhs->[0]+1, $lhs->[1]+0 ], # se corner
        [ $lhs->[0]+0, $lhs->[1]+1 ], # nw corner
        [ $lhs->[0]+1, $lhs->[1]+1 ], # ne corner
    );

    my @rhs = (
        [ $rhs->[0]+0, $rhs->[1]+0 ], # sw corner
        [ $rhs->[0]+1, $rhs->[1]+0 ], # se corner
        [ $rhs->[0]+0, $rhs->[1]+1 ], # nw corner
        [ $rhs->[0]+1, $rhs->[1]+1 ], # ne corner
    );

    my $max_x = $lhs[0][0]; my $min_x = $max_x; my $max_y = $lhs[0][1]; my $min_y = $max_y;
    for(@lhs,@rhs) {
        $max_x = $_->[0] if $_->[0] > $max_x;
        $min_x = $_->[0] if $_->[0] < $min_x;
        $max_y = $_->[1] if $_->[1] > $max_y;
        $min_y = $_->[1] if $_->[1] < $min_y;
    }

    my (@range, @domain) = ();

    if( $lhs->[0] < $rhs->[0] ) {
        @range = ( $lhs->[0] .. $rhs->[0]-1 );

    } elsif( $lhs->[0] > $rhs->[0] ) {
        @range = ( $rhs->[0] .. $lhs->[0]-1 );
    }

    if( $lhs->[1] < $rhs->[1] ) {
        @domain = ( $lhs->[1] .. $rhs->[1]-1 );

    } elsif( $lhs->[1] > $rhs->[1] ) {
        @domain = ( $rhs->[1] .. $lhs->[1]-1 );
    }

    warn "---= lhs=[@$lhs]; rhs=[@$rhs]; $min_x<=x<=$max_x; $min_y<=y<=$max_y;\n";

    my @results = ();
    LHS: for my $l (@lhs) { unshift @results, [];
    RHS: for my $r (@rhs) { unshift @{ $results[0] }, LOS_YES;

        warn "\tl=(@$l); r=(@$r); range=[@range]; domain=[@domain];\n";

        my $x_dir = ($l->[0] < $r->[0] ? "e" : "w");
        my $y_dir = ($l->[1] < $r->[1] ? "s" : "n");

        if( $l->[0] == $r->[0] ) {
            for my $y (@domain) {
                my $x = $l->[0];
                my @tile_locs = ([ $x, $y-1 ]);

                my $this_open = 0;
                for my $tl (@tile_locs) {
                    my $od = $this->{_the_map}[ $tl->[1] ][ $tl->[0] ]{od}{ $y_dir };

                    if( ref $od ) {
                        $od = $od->{'open'};
                        warn "\t\tX=l0=$x; Y=$y; tl=[@$tl]; od=door($od); y_dir=$y_dir;\n";

                    } else {
                        warn "\t\tX=l0=$x; Y=$y; tl=[@$tl]; od=$od; y_dir=$y_dir;\n";
                    }

                    $this_open ++ if $od;
                }

                if( $this_open < @tile_locs ) {
                    my $dl = sqrt( ($lhs->[0] - $x)**2 + ($lhs->[1] - $y)**2 );
                    my $dr = sqrt( ($rhs->[0] - $x)**2 + ($rhs->[1] - $y)**2 );

                    my $c = ($dl<$dr ? LOS_IGNORABLE_COVER : LOS_COVER);
                    $results[0][0] = $c if $c > $results[0][0];

                    # next RHS; # we don't skip ahead here in case there is LOS_COVER for both the LHS and the RHS!
                }
            }

        } else {
            # not vertical
            my $m = ($r->[1]-$l->[1]) / ($r->[0]-$l->[0]);
            my $b = $l->[1] - $m * $l->[0];

            for my $x (@range) {
                my $y = $m * $x + $b;

                my @tile_locs = ();
                if( $y >= $min_y and $y <= $max_y ) {
                    @tile_locs = ([ $x-1, int $y]);
                    if( $y == (int $y) and $m != 0 ) {
                        push @tile_locs, [$x-1, $y-1];
                    }
                }

                my $this_open = 0;
                for my $tl (@tile_locs) {
                    my $od = $this->{_the_map}[ $tl->[1] ][ $tl->[0] ]{od}{ $x_dir };

                    if( ref $od ) {
                        $od = $od->{'open'};

                        warn "\t\tX=$x; y=$y; (m=$m; b=$b); tl=[@$tl]; od=door($od); x_dir=$x_dir;\n";

                    } else {
                        warn "\t\tX=$x; y=$y; (m=$m; b=$b); tl=[@$tl]; od=$od; x_dir=$x_dir;\n";
                    }

                    $this_open ++ if $od;
                }

                if( $this_open < @tile_locs ) {
                    my $dl = sqrt( ($lhs->[0] - $x)**2 + ($lhs->[1] - $y)**2 );
                    my $dr = sqrt( ($rhs->[0] - $x)**2 + ($rhs->[1] - $y)**2 );

                    my $c = ($dl<$dr ? LOS_IGNORABLE_COVER : LOS_COVER);
                    $results[0][0] = $c if $c > $results[0][0];

                    # next RHS; # we don't skip ahead here in case there is LOS_COVER for both the LHS and the RHS!
                }
            }

            if( $m != 0 ) {
                for my $y (@domain) {
                    my $x = ($y-$b)/$m;

                    my @tile_locs = ();
                    if( $x >= $min_x and $x <= $max_x ) {
                        @tile_locs = ([ int $x, $y-1 ]);
                        if( $x == (int $x) ) {
                            push @tile_locs, [$x-1, $y-1];
                        }
                    }

                    my $this_open = 0;
                    for my $tl (@tile_locs) {
                        my $od = $this->{_the_map}[ $tl->[1] ][ $tl->[0] ]{od}{ $y_dir };

                        if( ref $od ) {
                            $od = $od->{'open'};

                            warn "\t\tx=$x; Y=$y; (m=$m; b=$b); tl=[@$tl]; od=door($od); y_dir=$y_dir\n";

                        } else {
                            warn "\t\tx=$x; Y=$y; (m=$m; b=$b); tl=[@$tl]; od=$od; y_dir=$y_dir\n";
                        }

                        $this_open ++ if $od;
                    }

                    if( $this_open < @tile_locs ) {
                        my $dl = sqrt( ($lhs->[0] - $x)**2 + ($lhs->[1] - $y)**2 );
                        my $dr = sqrt( ($rhs->[0] - $x)**2 + ($rhs->[1] - $y)**2 );

                        my $c = ($dl<$dr ? LOS_IGNORABLE_COVER : LOS_COVER);
                        $results[0][0] = $c if $c > $results[0][0];

                        # next RHS; # we don't skip ahead here in case there is LOS_COVER for both the LHS and the RHS!
                    }
                }
            }
        }
    }}

    my $at_least_one_1  = 0;
    my $minimum_maximum = LOS_COVER+1;
    for my $lca (@results) {
        my $max = 0;
        for my $res (@$lca) {
            $at_least_one_1 = 1 if $res == 1;
            $max = $res if $res > $max;
        }

        $minimum_maximum = $max if $max < $minimum_maximum;
    }

    warn "---= FIN: minimum_maximum=$minimum_maximum; at_least_one_1=$at_least_one_1;";
    use Data::Dumper; $Data::Dumper::Indent = 0;
    warn Dumper(\@results)."\n\n";

    return LOS_NO unless $at_least_one_1; # there is no line of sight at all

    return $minimum_maximum;
}
=cut
