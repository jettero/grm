#!/usr/bin/perl
# vi:tw=0:
# $Id: greenies.pl 45.1009.XDA0VyAx9t5MalutcbQ2KNABSL0 2007-05-07 06:38:15 -0400 $

use strict;
use GD;

my $in_set = 0;

while(<STDIN>) {

    if( m/SET/ ) {
        $in_set ++;
        next;
    }

    my $image = GD::Image->new("marked.png");
    my $green = $image->colorAllocate(0, 200, 0);
    my $black = $image->colorAllocate(0, 0, 0);

    REDO: {
        while( m/\((\d+)[,\s]+(\d+)\).*?\((\d+)[,\s]+(\d+)\)/g ) {
            my @lhs = map {$_*23} ($1, $2);
            my @rhs = map {$_*23} ($3, $4);

            $image->line( @lhs=>@rhs, $green );
            $image->filledEllipse(@lhs, 5,5, $green);
            $image->filledEllipse(@rhs, 6,5, $green);
            $image->ellipse(@lhs, 5,5, $black);
            $image->ellipse(@rhs, 5,5, $black);
        }

        if( $in_set ) {
            $_ = <STDIN>;
            redo unless m/DONE/;
        }
    }

    open my $out, ">", "marked_greenies.png" or die $!;
    print $out $image->png;
    close $out;

    system qw(xv marked_greenies.png);
    unlink "marked_greenies.png" or die $!;
}
