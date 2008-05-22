
use strict;
use Test;

plan tests => 3;

use XML::Parser;

eval {
    do {
        open my $testxml, ">test.xml" or die $!;
        open my $testdtd, ">test.dtd" or die $!;
        open my $testxsl, ">test.xsl" or die $!;


print $testxml <<EOF
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE test SYSTEM "test.dtd">
<?xml-stylesheet type="text/xsl" href="test.xsl"?>

<test>
  <a>
    <b c="0">
    </b>
  </a>
</test>
EOF
;

print $testdtd <<EOF

<!ELEMENT test (a*)>
<!ELEMENT a (b*)>
<!ELEMENT b EMPTY>

<!ATTLIST b c CDATA #REQUIRED>

EOF
;

print $testxsl <<EOF
<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output type="text" encoding="utf-8"/>

<xsl:template match="/test"><xsl:text>test</xsl:text></xsl:template>

</xsl:stylesheet>
EOF
;
    };

    my $p1 = XML::Parser->new(ErrorContext=>2, ParseParamEnt=>1, $ENV{DEBUG} ? (Style => 'Debug') : ());
       $p1->parsefile('test.xml');
};
warn "WARNING: failed to parse xml docs: $@" if $@;

ok($@ ? 0 : 1);

eval {
    my @doom = (
        Handlers=>{ExternEnt => sub {
            my ($base, $name) = @_[1,2];
            my $fname = ($base ? File::Spec->catfile($base, $name) : $name);

            open _TESTHANDLE, $fname or
            open _TESTHANDLE, $name  or return undef;

          # warn "file=*_TESTHANDLE; ref-type=" . ref *_TESTHANDLE;

            *_TESTHANDLE;
        }},
    );

    my $p2 = XML::Parser->new(ErrorContext=>2, ParseParamEnt=>1, $ENV{DEBUG} ? (Style => 'Debug') : (), @doom);
       $p2->parsefile('test.xml');
};
warn "WARNING: failed to parse xml docs: $@" if $@;

ok( $@ ? 0 : 1 );

eval {
    my @doom = (
        Handlers=>{ExternEnt => sub {
            my ($base, $name) = @_[1,2];
            my $fname = ($base ? File::Spec->catfile($base, $name) : $name);

            my $fh;
            open $fh, $fname or
            open $fh,  $name or return undef;

          # warn "file=$fh ref-type=" . ref $fh;

            $fh;
        }},
    );

    my $p2 = XML::Parser->new(ErrorContext=>2, ParseParamEnt=>1, $ENV{DEBUG} ? (Style => 'Debug') : (), @doom);
       $p2->parsefile('test.xml');
};
warn "WARNING: failed to parse xml docs: $@" if $@;

ok( my $result = ($@ ? 0 : 1) );

no warnings 'void';
$result;
