#!/usr/bin/perl

use strict;

my $t = test->new("test");
   $t->quantity(5);
   $t->nonunique;
   $t+=7;

print "", $t+0, " =? 12\n";

package test;

use strict;
use overload fallback => 1, bool => sub{1}, '0+' => \&n, "-=" => \&me, "+=" => \&pe;

sub new { my $class = shift; my $val = shift; bless {q=>1, u=>1, v=>$val}, $class }

sub n {
    my $this = shift;

    return $this->{q};
}

sub pe {
    my $this = shift;
    my $that = shift;

    $this->{q} += $that;
}

sub me {
    my $this = shift;
    my $that = shift;
    my $ordr = shift;

    return ($this->{q} = ($that - $this->{q})) if $ordr;
    $this->{q} -= $that;
}

sub quantity { my $this = shift; $this->{q}=0+shift; }

our %item_counts;
sub nonunique { my $this = shift; $this->{c} = push @{$item_counts{$this->{v}}}, $this; }
sub DESTROY {
    my $this = shift;

    delete $item_counts{$this->{v}}[$this->{c}] if exists $this->{c};
}
