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
   make clean setup TOP_MODULE_NAME=$i
   make -C ../${i}_V* sim-run VCD=0
done
