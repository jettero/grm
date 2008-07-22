# vi:set syntax=perl:

use 5.008;
use Cwd;
use ExtUtils::MakeMaker;

open OLDERR, ">&", \*STDERR or die "unable to dup: $!";
open STDERR, ">/dev/null" or die "unable to close STDERR: $!";
unlink "xmllint.res";
my @cmd = qw(xmllint --path xmllint.test/t2 --postvalid --noout);
if( (system(@cmd, 'xmllint.test/map.xml') == 0) and (system(@cmd, 'xmllint.test/bad.xml') != 0) ) {
    open my $out, ">xmllint.res" or die "couldn't open a file, this makefile is dooooomed: $!";
}
open STDERR, ">&OLDERR" or die "unable to reopen STDERR: $!";

unless( -f "xmllint.res" ) {

    print "\n\nYour xmllint doesn't seem to work quite like the author's\n";
    print "and the test just isn't that important anyway. (Skipping.)\n\n";
}

my @image_exporters = (
    GD        => 0,
    'GD::SVG' => 0,
);

my @editor_prereqs = (
    'Gtk2'                         => 0,
    'Gtk2::Ex::Dialogs'            => 0,
    'Gtk2::Ex::Simple::Menu'       => 0,
    Storable                       => 0,
    'Data::Dump'                   => 0,
    'HTTP::Status'                 => 0,
    POE                            => 0,
    'POE::Component::Server::HTTP' => 0,
    @image_exporters,
);

my @to_add;
    my $res = "y";
    unless( -f "MANIFEST.SKIP" ) {
        print "Include pre-reqs for the Image Exporters (GD, GD::SVG, etc) [N/y]? ";
        $res = <STDIN>;
    }
    push @to_add, @image_exporters if $res =~ m/[Yy]/;

    my $res = "y";
    unless( -f "MANIFEST.SKIP" ) {
        print "Include pre-reqs for the Editor (Gtk2, POE, GD, et al) [N/y]? ";
        $res = <STDIN>;
    }
    push @to_add, @editor_prereqs if $res =~ m/[Yy]/;

WriteMakefile(
    'NAME'         => 'Games::RolePlay::MapGen',
    'VERSION_FROM' => 'MapGen.pm',

    'PREREQ_PM'     => { 
        'version' => 0,

        @to_add,

        'Software::License::LGPL_2_1' => 0,
        'Math::Round' => 0,
        'Math::Trig'  => 0,
        'List::Util'  => 0,
        'XML::Simple' => 0,
        'Tie::IxHash' => 0,
        'XML::XPath'  => 0, # I versioned these up during the bsd-6.1-hates-me senerio # 1.13,
        'XML::Parser' => 0, # I versioned these up during the bsd-6.1-hates-me senerio # 1.36,
        'Test' => 1.25,     # NOTE: it was never bsd, it was XML::Parser that was hating me

        # These are just for t/05_export.t
        'File::Slurp'     => 0, # <-- this, I could just as well have used ``...
        'Algorithm::Diff' => 0, # <-- this is used automatcially by the test harness
    },

    OBJECT => "mq.o",

    clean => { FILES => "xml_parser.res test.* xmllint.res m*.txt map.png *.log *.map [0-9][0-9]_*.xml m*.xml 10_groups.* map.dumper.* *.tnc log" },
);
