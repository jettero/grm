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

if( -f "xmllint.res" ) {

} else {
    print "\n\nYour xmllint doesn't seem to work quite like the author's\n";
    print "and the test just isn't that important anyway. (Skipping.)\n\n";
}

if( (my $c = getcwd()) and chdir "bsd6.1" ) {
    my $r = do "test.pl";

    chdir $c or die "couldn't cd back from bsd6.1 xml test dir: $!";

    if( $r and not $@ ) {
        open my $out, ">xml_parser.res";

    } else {
        warn "\nYour XML::Parser doesn't seem to be able to parse valid XML.  Skipping tests.\n";
        warn "Most likely the XMLimporter Games::RolePlay::MapGen will not work correctly.\n\n";
        sleep 1;
    }
}

WriteMakefile(
    'NAME'         => 'Games::RolePlay::MapGen',
    'VERSION_FROM' => 'MapGen.pm',
    'PREREQ_PM'     => { 
        'Software::License::LGPL_2_1' => 0,
        'XML::Simple' => 0,
        'Tie::IxHash' => 0,
        'XML::XPath'  => 0, # I versioned these up during the bsd-6.1-hates-me senerio # 1.13,
        'XML::Parser' => 0, # I versioned these up during the bsd-6.1-hates-me senerio # 1.36,
        'Test' => 1.25,

        # These are just for t/05_export.t
        'File::Slurp'     => 0, # <-- this, I could just as well have used ``...
        'Algorithm::Diff' => 0, # <-- this is used automatcially by the test harness
    },

    clean => { FILES => "xml_parser.res xmllint.res m*.txt map.png *.log *.map [0-9][0-9]_*.xml m*.xml 10_groups.* map.dumper.* *.tnc log" },
);
