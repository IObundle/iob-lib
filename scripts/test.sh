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
   if [ -z "`ls hardware/src | grep -i asym`" ]; then
      IS_ASYM=0
   else
      IS_ASYM=1
   fi

   make sim MODULE=$i IS_ASYM=$IS_ASYM VCD=0
done
