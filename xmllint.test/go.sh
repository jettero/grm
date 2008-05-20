#!/bin/bash

/usr/bin/xmllint --path t2 --postvalid --noout map.xml 2>/dev/null && echo test1: good
/usr/bin/xmllint --path t2 --postvalid --noout bad.xml 2>/dev/null || echo test2: good
