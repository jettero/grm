
use strict;
use Test;

plan tests => 1;

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

my $result = ($@ ? 0 : 1);
ok($result);

no warnings 'void';
$result;
