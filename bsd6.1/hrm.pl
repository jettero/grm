#!/usr/bin/perl

use strict;
use XML::Parser;

open STDERR, ">hrm.log" or die $!;

my $p1 = new XML::Parser(Style => 'Debug');
   $p1->parsefile('map.xml');

