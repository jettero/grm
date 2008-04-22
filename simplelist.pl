#!/usr/bin/perl -w

use Data::Dumper;
use Gtk2 '-init';
use Gtk2::SimpleList;

use constant TRUE  => 1;
use constant FALSE => 0;

$categories = Gtk2::SimpleList->new ('Categories' => 'text');
$categories->set_headers_visible(FALSE);
@{$categories->{data}} = qw/Meat Beer Pizza Pasta Soda Juice Rabbitfood/;

$categories->set_has_tooltip(TRUE); # NOTE: thought this might help (nope)

$path = Gtk2::TreePath->new_from_indices(0);
$tip = new Gtk2::Tooltip;
$tip->set_text("tooltip test");
$categories->set_tooltip_row($tip, $path);

# NOTE: thought this might help, but I fail to see how it would
# $categories->signal_connect( 'query-tooltip' => sub {
#     warn Dumper({args=>\@_, useless=>{tip=>$tip, path=>$path}});
# });

$window = Gtk2::Window->new;
$window->set_title ('SimpleList examples');
$window->signal_connect (delete_event => sub {Gtk2->main_quit; TRUE});
$window->set_default_size (800,600);
$window->add($categories);
$window->show_all;

Gtk2->main;
