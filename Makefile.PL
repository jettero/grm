# vi:set syntax=perl:

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Games::RolePlay::MapGen',
    'VERSION_FROM' => 'MapGen.pm',
    # 'PREREQ_PM'     => { 
        # 'Number::Format'         => 0,
        # 'Math::Units'            => 0,
        # 'Math::Algebra::Symbols' => 0,
    # },


    clean => { FILES => "*.txt *.png" },
);
