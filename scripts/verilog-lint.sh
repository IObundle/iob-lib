#!/usr/bin/env bash
# run the command below for all files given as command line arguments
set -e
cat $@ > /tmp/combined
verible-verilog-lint  --rules_config $IOB_LIB_PATH/verible-lint.rules /tmp/combined
rm /tmp/combined
