#!/usr/bin/perl

package blarg;
use common::sense;
use Storable qw(freeze thaw);

{
    my $going;
    sub STORABLE_freeze {
        return if $going;
        warn "before";
        $going = 1;
        my $str = freeze($_[0]);
        $going = 0;
        warn "after";
        $str;
    }

    sub STORABLE_thaw {
        my $this = shift;
        my $cloning = shift;
        %$this = %{ thaw(shift) };
    }
}

package main;

use common::sense;
use Storable qw(freeze thaw);

my $b = bless {p=>7}, 'blarg';
my $c = freeze($b);
my $d = thaw($c);

warn "c: $c";
warn "ja1" if $d->{p} == 7;
warn "ja2" if $d->isa("blarg");
