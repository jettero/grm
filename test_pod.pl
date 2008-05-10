#!/usr/bin/perl -Iblib/lib

BEGIN { system("make") }

use strict;
use Gtk2 -init;
use Gtk2::Ex::PodViewer;

my $viewer = Gtk2::Ex::PodViewer->new;
   $viewer->load('Games::RolePlay::MapGen::Editor');
   $viewer->show;  # see, it's a widget!

my $vp = Gtk2::Viewport->new(undef,undef);
   $vp->add($viewer);

my $scwin = Gtk2::ScrolledWindow->new;
   $scwin->set_policy('automatic', 'automatic');
   $scwin->add($vp);

my $window = Gtk2::Window->new;
   $window->add($scwin);
   $window->set_size_request(600,450);
   $window->show_all;

Gtk2->main;
