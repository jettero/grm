#!/bin/bash
# $Id: go.sh,v 1.2 2005/03/23 23:35:24 jettero Exp $

make || exit 1

perl -Iblib/lib -MExtUtils::Command::MM -e 'test_harness(0, "blib/lib", "blib/arch")' t/03_tools.t || exit 1

# perl -Iblib/lib -MExtUtils::Command::MM -e 'test_harness(0, "blib/lib", "blib/arch")' t/05_generate.t || exit 1
# cat map.txt || exit 1
