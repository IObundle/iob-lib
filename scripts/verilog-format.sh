#!/usr/bin/env bash
# run the command below for all files given as command line arguments
verible-verilog-format --inplace `cat $IOB_LIB/scripts/verible-format.rules | tr '\n' ' '` $@
