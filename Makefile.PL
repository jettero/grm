# vi:set syntax=perl:

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Games::RolePlay::MapGen',
    'VERSION_FROM' => 'MapGen.pm',
    'PREREQ_PM'     => { 
        'XML::Simple' => 0,
        'Tie::IxHash' => 0,
        'XML::XPath'  => 0,
    },

    clean => { FILES => "m*.txt *.png *.log *.map [0-9][0-9]_*.xml m*.xml map.dumper.* log" },
);
