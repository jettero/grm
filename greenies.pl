#!/usr/bin/perl
# vi:tw=0:
# $Id: greenies.pl 29.809.qugNSvzg7pcICj4FGURXNZQhxIk 2007-05-06 14:18:12 -0400 $

use strict;
use GD;

while(<STDIN>) {
    if( m/\((\d+)[,\s]+(\d+)\).*\((\d+)[,\s]+(\d+)\)/ ) {
        my @lhs = map {$_*23} ($1, $2);
        my @rhs = map {$_*23} ($3, $4);
        my $image = GD::Image->new("marked.png");
        my $green = $image->colorAllocate(0, 200, 0);
        my $black = $image->colorAllocate(0, 0, 0);

        $image->line( @lhs=>@rhs, $green );
        $image->filledEllipse(@lhs, 5,5, $green);
        $image->filledEllipse(@rhs, 5,5, $green);
        $image->ellipse(@lhs, 5,5, $black);
        $image->ellipse(@rhs, 5,5, $black);

        open my $out, ">", "marked_greenies.png" or die $!;
        print $out $image->png;
        close $out;

        system qw(xv marked_greenies.png);
        unlink "marked_greenies.png" or die $!;
    }
}
