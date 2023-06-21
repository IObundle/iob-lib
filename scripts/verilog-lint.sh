#!/usr/bin/env bash
# run the command below for all files given as command line arguments
set -e
cat $@ > verible-cat.v
verible-verilog-lint  --rules_config $IOB_LIB_PATH/verible-lint.rules verible-cat.v

