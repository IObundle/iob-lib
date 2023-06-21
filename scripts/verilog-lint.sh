#!/usr/bin/env bash
# run the command below for all files given as command line arguments
set -e

TMP_FILENAME=~linter_files_combined.tmp

rm -f $TMP_FILENAME

# Create array of tuples to store filenames and starting line numbers
declare -A files_linenumber

idx=0
# Combine all files into one file, separating them with a comment, and creating an array for each file
for file in $@;
do
  # Add comment to specify original file name
  echo -e "\n////////////////////////////////////////////////////////////////////" >> $TMP_FILENAME
  echo "// Original file $file" >> $TMP_FILENAME
  echo -e ////////////////////////////////////////////////////////////////////"\n\n" >> $TMP_FILENAME
  
  # Store this filename and corresponding start line number into a dictionary
  files_linenumber[$idx,0]="$file"
  files_linenumber[$idx,1]=`wc -l $TMP_FILENAME | cut -d' ' -f1`
  idx=$(($idx+1))

  # Add file content
  cat $file >> $TMP_FILENAME
done
total_files_combined=$idx

# Lint the temporary combined file and remove it if successful
ERROR_STR=`verible-verilog-lint --rules_config $IOB_LIB_PATH/verible-lint.rules $TMP_FILENAME 2>&1 && rm $TMP_FILENAME || true`
#echo "'$ERROR_STR'" #DEBUG

# Exit if there was no error
if [ "$ERROR_STR" = "" ]; then
  exit 0
fi

# For each error line, find the correct original file
while IFS= read -r line; do
  #echo "Processing line: $line" #DEBUG
  LINE_NUM=`echo $line | cut -d: -f2`
  ERROR_LINE=`echo $line | cut -d: -f3-`
  #echo "$LINE_NUM $ERROR_LINE" #DEBUG
  # Find which file contains the current line number
  for idx in `seq 0 $(($total_files_combined-1))`;
  do
    #echo -e "\n\n$idx ${files_linenumber[$idx,0]} ${files_linenumber[$idx,1]}" #DEBUG
    
    # If this is the last file
    # or the line number of the next file is greater than the current line number
    # then the current file has the error.
    if [ $idx -eq $(($total_files_combined-1)) ] || [ "${files_linenumber[$(($idx+1)),1]}" -gt "$LINE_NUM" ]; then
      #echo "Error is in file: ${files_linenumber[$(($idx)),0]}" #DEBUG
      # Print error line with format: 'Error: <filename>:<linenumber>:<message>'
      echo "Error: ${files_linenumber[$(($idx)),0]}:$(($LINE_NUM-${files_linenumber[$(($idx)),1]})):$ERROR_LINE"
      break
    fi
  done
done <<< "$ERROR_STR"

exit 1
