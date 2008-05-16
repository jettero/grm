# vi:set syntax=perl:

use 5.008;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Games::RolePlay::MapGen',
    'VERSION_FROM' => 'MapGen.pm',
    'PREREQ_PM'     => { 
        'Software::License::LGPL_2_1' => 0,
        'XML::Simple' => 0,
        'Tie::IxHash' => 0,
        'XML::XPath'  => 0,
        'Test' => 1.25,

        # These are just for t/05_export.t
        'File::Slurp'     => 0, # <-- this, I could just as well have used ``...
        'Algorithm::Diff' => 0, # <-- this is used automatcially by the test harness
    },

    clean => { FILES => "m*.txt map.png *.log *.map [0-9][0-9]_*.xml m*.xml 10_groups.* map.dumper.* *.tnc log" },
);
