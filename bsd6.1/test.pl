#!/usr/bin/perl

use strict;
use XML::Parser;

eval {
    my $p1 = XML::Parser->new(ErrorContext=>2, ParseParamEnt=>1, $ENV{DEBUG} ? (Style => 'Debug') : ());
       $p1->parsefile('test.xml');
};

warn "\nProblem with valid xml: $@\n" if $@;

$@ ? 0 : 1;
