
    for my $rn (1 .. &str_eval($opts->{num_rooms})) {
        my @size = $this->_gen_room_size( $opts );

        $size[0] = $opts->{x_size} if $size[0] > $opts->{x_size};
        $size[1] = $opts->{y_size} if $size[1] > $opts->{y_size};

        my @min_pos = (0, 0);
        my @max_pos = ( $opts->{x_size} - $size[0], $opts->{y_size} - $size[1] );

        my $redos = $opts->{room_fit_redos} || 100;
        FIND_A_SPOT_FOR_IT: {
            my @spot = map( irange($min_pos[$_], $max_pos[$_]), 0..1 );

            my $no_collision = 1;
            for my $y ($spot[1]..($size[1]-1)+$spot[1]) {
                for my $x ($spot[0]..($size[0]-1)+$spot[0]) {
                    if( $map[$y][$x]{type} ) {
                        $no_collision = 0;
                        last;
                    }
                }
            }

            if( $no_collision ) {
                my $group = &_group;
                   $group->{name}     = "Room #$rn";
                   $group->{loc_size} = "$size[0]x$size[1] ($spot[0], $spot[1])";
                   $group->{type}     = "room";
                   $group->{size}     = [@size];
                   $group->{loc}      = [@spot];

                for my $y ($spot[1]..($size[1]-1)+$spot[1]) {
                    for my $x ($spot[0]..($size[0]-1)+$spot[0]) {
                        my $tile = $map[$y][$x];
                        $tile->{group}   = $group;
                        $tile->{type}    = "room";
                        $tile->{visited} = 1;
                        $tile->{od}      = {n=>1, s=>1, e=>1, w=>1}; # open every direction... close edges below
                    }
                }

                for my $y ($spot[1]..($size[1]-1)+$spot[1]) {
                    $map[$y][ $spot[0]                ]->{od}{w} = 0;
                    $map[$y][ ($size[0]-1) + $spot[0] ]->{od}{e} = 0;
                }

                for my $x ($spot[0]..($size[0]-1)+$spot[0]) {
                    $map[ $spot[1]                ][$x]->{od}{n} = 0;
                    $map[ ($size[1]-1) + $spot[1] ][$x]->{od}{s} = 0;
                }

                push @groups, $group;

            } else {
                redo unless --$redos < 1;
            }
        }
    }
