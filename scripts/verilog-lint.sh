#!/usr/bin/env bash
# run the command below for all files given as command line arguments
set -e

TMP_FILENAME=~linter_files_combined.tmp

rm -f $TMP_FILENAME
for file in $@;
do
  echo -e "\n////////////////////////////////////////////////////////////////////" >> $TMP_FILENAME
  echo "// File $file" >> $TMP_FILENAME
  echo -e ////////////////////////////////////////////////////////////////////"\n\n" >> $TMP_FILENAME
  cat $file >> $TMP_FILENAME
done
# Lint the temporary combined file and remove it if successful
verible-verilog-lint  --rules_config $IOB_LIB_PATH/verible-lint.rules $TMP_FILENAME && rm $TMP_FILENAME
