#!/bin/bash
# $Id: go.sh,v 1.3 2005/03/23 23:37:17 jettero Exp $

make || exit 1

perl -Iblib/lib -MExtUtils::Command::MM -e 'test_harness(0, "blib/lib", "blib/arch")' t/05*.t || exit 1
cat map.txt || exit 1
