#!/bin/bash

# set -x
# trap "sleep 1" ERR
# trap "exit 1" SIGINT # fucking die when I fucking say

perl Makefile.PL
make

perl -Iblib/{arch,lib} ./grm_editor

