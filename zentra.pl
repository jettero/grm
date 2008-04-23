#!/usr/bin/perl
use warnings;
use strict;

use Data::Dumper;
use Gtk2 '-init';
use Gtk2::SimpleList;
use constant TRUE  => 1;
use constant FALSE => 0;

my $categories = Gtk2::SimpleList->new ('Categories' => 'text');
$categories->set_headers_visible(FALSE);

@{$categories->{data}} = qw/Meat Beer Pizza Pasta Soda Juice Rabbitfood/;

$categories->set_has_tooltip(TRUE); # NOTE: thought this might help (nope)

my $window = Gtk2::Window->new;
$window->set_title ('SimpleList examples');
$window->signal_connect (delete_event => sub {Gtk2->main_quit; TRUE});
$window->set_default_size (800,600);
$window->add($categories);
$window->show_all;


# This is our little tooltip window.
my $tooltip_label = Gtk2::Label->new;
my $tooltip = Gtk2::Window->new('popup');
$tooltip->set_decorated(0);
$tooltip->set_position('mouse'); # We'll choose this to start with.
$tooltip->add($tooltip_label);
my $tooltip_displayed = FALSE;

my $selected_row = 0;
my $selected_col = 0;

=head1
my $popup_hash;
my $row = 0;
foreach my $child(@children) {
   my $child_iter = $model->append ($iter);
   $model->set ($child_iter,
			0, $child->{label},	
			1, $child->{this},	
			2, $child->{that},	
			3, $child->{what},	
			4, undef,			
   );
   
   # We'll populate the hash here
   my $path = "0:".$row;
   $popup_hash->{$path}->{1} = $child->{this_popup};
   $popup_hash->{$path}->{2} = $child->{that_popup};
   $popup_hash->{$path}->{3} = $child->{what_popup};
   $row++;
   
}
print Dumper $popup_hash;
=cut

$categories->signal_connect('motion-notify-event' =>
	sub {        
		my ($self, $event) = @_;
		my ($path, $column, $cell_x, $cell_y) = $categories->get_path_at_pos ($event->x, $event->y);
		
		if ($path) {
			my $model = $categories->get_model;
			my $i = $column->{column_number};
			my $row = $path->to_string();
			
			# If a new cell is selected, then hide the tooltip
			# It'll be re-shown as required by the code down under
			if ($selected_row ne $row or $selected_col != $i) {
				$tooltip->hide;
				$tooltip_displayed = FALSE;
				$selected_row = $row;
				$selected_col = $i;
			}
			
			if ($row) {

				# Pick that popup string from our hash
                		#my $str = $popup_hash->{$row}->{$i};
				my $str = " row  $row  ";

				if ($str) {
					$tooltip_label->set_label($str);
					if (!$tooltip_displayed) {
						$tooltip->show_all;
						my ($thisx, $thisy) = $tooltip->window->get_origin;
						# I want the window to be a bit away from the mouse pointer.
						# Just a personal choice :)
						$tooltip->move($thisx +10, $thisy+10);
						$tooltip_displayed = TRUE;
					} 
				} 
			}
			return 0;
		}
	}
);

Gtk2->main;
