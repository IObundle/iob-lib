#!/usr/bin/env bash

set -e

#find directories containing testbenches
# TBS=`find hardware | grep _tb.v | grep -v include`

# TODO working only for specific modules for now
TBS+=" hardware/modules/div/iob_div_pipe/iob_div_pipe_tb.v"
TBS+=" hardware/modules/div/iob_div_subshift/iob_div_subshift_tb.v"
TBS+=" hardware/modules/div/iob_div_subshift_frac/iob_div_subshift_frac_tb.v"
TBS+=" hardware/modules/axis2axi/axis2axi_tb.v"
TBS+=" hardware/modules/iob_asym_converter/iob_asym_converter_tb.v"
TBS+=" hardware/modules/regfile/iob_regfile_sp/iob_regfile_sp_tb.v"

#extract respective directories
for i in $TBS; do TB_DIRS+=" `dirname $i`" ; done

#extract respective modules - go back MODULE/hardware/simulation/src
# for i in $TB_DIRS; do MODULES+=" `basename $(builtin cd $i/../../..; pwd)`" ; done
for i in $TB_DIRS; do MODULES+=" `basename $i`" ; done

# #run tests
# for i in $MODULES; do
#     echo "$i"
# done

#run tests
for i in $MODULES; do
   make clean setup TOP_MODULE_NAME=$i
   make -C ../${i}_V* sim-run VCD=0
done
