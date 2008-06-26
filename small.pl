#!/usr/bin/perl

use strict;

my $t = test->new("test");
   $t->nonunique;  # comment out this line to avoid segmentation fault
   $t+=7;       # or comment out this line to avoid segmentation fault

package test;

use strict;
use overload fallback => 1, bool => sub{1}, "+=" => \&pe;

sub new { my $class = shift; my $val = shift; bless {q=>1, v=>$val}, $class }

sub pe {
    my $this = shift;
    my $that = shift;

    $this->{q} += $that;
}

sub quantity { my $this = shift; $this->{q} = shift }

our %item_counts;
sub nonunique { my $this = shift; $this->{c} = push @{$item_counts{$this->{v}}}, $this; }
