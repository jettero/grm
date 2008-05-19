#!/usr/bin/perl

use strict;
use XML::Parser;

my $p1 = new XML::Parser(Style => 'Debug');
   $p1->parsefile('map.xml');

