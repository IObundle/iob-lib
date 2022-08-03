#!/usr/bin/env bash

set -e

#find directories containing testbenches
TBS=`find hardware | grep _tb.v`

#extract respective directories
for i in $TBS; do TB_DIRS+=" `dirname $i`" ; done

#extract respective modules
for i in $TB_DIRS; do MODULES+=" `basename $i`" ; done

#run tests
for i in $MODULES; do make sim MODULE=$i VCD=0 TEST_LOG=">> test.log"; done

if [ `grep -c "ERROR" test.log` != 0 ]; then exit 1; fi
