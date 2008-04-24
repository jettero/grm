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
    },

    clean => { FILES => "m*.txt map.png *.log *.map [0-9][0-9]_*.xml m*.xml 10_groups.* map.dumper.* log" },
);
