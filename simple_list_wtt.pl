
use strict;
use Data::Dumper;
use Gtk2 '-init';
use Gtk2::SimpleList;

use constant TRUE  => 1;
use constant FALSE => 0;

my $categories = Gtk2::SimpleList->new ('Categories' => 'text');
$categories->set_headers_visible(FALSE);
@{$categories->{data}} = qw/Meat Beer Pizza Pasta Soda Juice Rabbitfood/;

# This turns on the tooltip event monitoring in the widget...
$categories->set_has_tooltip(TRUE);

# Tooltip event monitoring causes the query-tooltip signal to be emitted.
$categories->signal_connect (query_tooltip => sub {
    my ($widget, $x, $y, $keyboard_mode, $tooltip) = @_;

    # First, find out where the pointer is:
    my $path = $categories->get_path_at_pos ($x, $y);

    # If we're not pointed at a row, then return FALSE to say
    # "don't show a tip".
    return FALSE unless $path;

    # Otherwise, ask the TreeView to set up the tip's area according
    # to the row's rectangle.
    $categories->set_tooltip_row($tooltip, $path);

    # And then load it up with some meaningful text.  This is much
    # more interesting when you have columns that aren't visible,
    # or the TreeView is too narrow to see all of your column.
    my $index = ($path->get_indices)[0];
    $tooltip->set_text("lawl: " . int(1+rand 200));

    # Return true to say "show the tip".
    return TRUE;
});

my
$window = Gtk2::Window->new;
$window->set_title ('SimpleList examples');
$window->signal_connect (delete_event => sub {Gtk2->main_quit; TRUE});
$window->add($categories);
$window->show_all;

Gtk2->main;

__END__
