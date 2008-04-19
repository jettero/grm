#!/usr/bin/perl -w

use Data::Dumper;
use Gtk2 '-init';
use Gtk2::SimpleList;

use constant TRUE  => 1;
use constant FALSE => 0;

$categories = Gtk2::SimpleList->new ('Categories' => 'text');
$categories->set_headers_visible(FALSE);
@{$categories->{data}} = qw/Meat Beer Pizza Pasta Soda Juice Rabbitfood/;

$window = Gtk2::Window->new;
$window->set_title ('SimpleList examples');
$window->signal_connect (delete_event => sub {Gtk2->main_quit; TRUE});
$window->set_default_size (800,600);
$window->add($categories);
$window->show_all;

Gtk2->main;
