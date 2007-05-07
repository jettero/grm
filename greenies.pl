#!/usr/bin/perl
# vi:tw=0:
# $Id: greenies.pl 66.1445.lhgFHt8XveWYOoIfdRw3V9/Ij+c 2007-05-07 09:17:05 -0400 $

use strict;
use GD;

my $in_set = 0;

while(<STDIN>) {
    my $drew = 0;

    if( m/SET/ ) {
        $in_set ++;
        next;
    }

    my $image = GD::Image->new("marked.png");
    my $green = $image->colorAllocate(0, 200, 0);
    my $red   = $image->colorAllocate(190, 0, 0);
    my $black = $image->colorAllocate(0, 0, 0);

    REDO: {
        while( m/\((\d+)[,\s]+(\d+)\).*?\((\d+)[,\s]+(\d+)\)/g ) {
            my @lhs = map {$_*23} ($1, $2);
            my @rhs = map {$_*23} ($3, $4);

            $image->line( @lhs=>@rhs, $green );
            $image->filledEllipse(@lhs, 5,5, $green);
            $image->filledEllipse(@rhs, 5,5, $green);
            $image->ellipse(@lhs, 5,5, $black);
            $image->ellipse(@rhs, 5,5, $black);

            $drew ++;
        }

        while( m/<(\d+)[,\s]+(\d+)>/g ) {
            my @p = map {$_*23+12} ($1, $2);

            $image->filledEllipse(@p, 9,9, $red);
            $image->ellipse(@p, 9,9, $black);

            $drew ++;
        }

        if( $in_set ) {
            $_ = <STDIN>;

            if( m/DONE/ ) {
                $in_set = 0;

            } else {
                redo;
            }
        }
    }

    if( $drew ) {
        open my $out, ">", "marked_greenies.png" or die $!;
        print $out $image->png;
        close $out;

        system qw(xv marked_greenies.png);
        unlink "marked_greenies.png" or die $!;
    }
}
