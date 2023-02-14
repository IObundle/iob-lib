#!/usr/bin/env bash

set -e

#find directories containing testbenches
TBS=`find hardware | grep _tb.v | grep -v include`

#extract respective directories
for i in $TBS; do TB_DIRS+=" `dirname $i`" ; done

#extract respective modules
for i in $TB_DIRS; do MODULES+=" `basename $i`" ; done

#run tests
for i in $MODULES; do
   make clean copy_srcs MODULE=$i
   if [ -z `ls hardware/src | grep -i asym` ]; then
      IS_ASYM=0
   else
      IS_ASYM=1
   fi
   make sim MODULE=$i IS_ASYM=$IS_ASYM VCD=0 TEST_LOG="| tee -a test.log"; 
done

if [ `grep -c "ERROR" test.log` != 0 ]; then exit 1; fi

#find all modules
LINT_EXPECTED=`find hardware -name "*_lint.expected"`

#extract respective directories
for i in $LINT_EXPECTED; do LINT_DIRS+=" `dirname $i`" ; done

#extract respective modules
for i in $LINT_DIRS; do LINT_MODULES+=" `basename $i`" ; done

#run tests
for i in $LINT_MODULES; do
   make lint-run MODULE=$i
   tail +33 spyglass_reports/moresimple.rpt > spyglass.rpt
   expected_file=$(find hardware -name $i*.expected) 
   diff -q $expected_file spyglass.rpt
done
