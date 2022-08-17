#!/usr/bin/env bash
#
# Run makefile targets for core and subcores
# Usage: ./subcore.sh [CORE_DIR] [TARGET]
#   [CORE_DIR]: path to top level Core
#   [TARGET]: makefile target to run in subcore
#
set -e

# Usage check
if [ "$#" -lt 2 ]; then
    echo "Usage: ./subcore.sh [CORE_DIR] [TARGET]"
    echo "[CORE_DIR]: path to top level Core"
    echo "[TARGET]: makefile target to run in subcore"
    exit 1
else
    core_dir=$1
    target=$2
fi

#find subcore directories
subcore_dirs=$(find "$core_dir/submodules/" -name info.mk -printf '%h\n')

#run makefile target for each subcore
for subcore_dir in $subcore_dirs
do
    make -C $subcore_dir $target
done

#run makefile target to core
make $target CORE_DIR=$core_dir
