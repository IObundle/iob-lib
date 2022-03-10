#!/bin/bash
set -e

RES="asic.tex" ;\
AREA=`grep -m1 "total" gates.rpt | awk '{print $3}'` ;\
NANDS=`grep -m1 "ND2CLD" gates.rpt | awk '{print $2}'` ;\
NAND_AREA=`grep -m1 "ND2CLD" gates.rpt | awk '{print $3}'` ;\
FFS=`grep -m1 "sequential" gates.rpt | awk '{print $2}'` ;\
PER=`grep -m1 "capture" timing.rpt | awk '{print $4}'` ;\
SLACK=`grep -m1 "slack" timing.rpt | awk '{print $4}' | grep -o '[^a-z]*'` ;\
GATES=`echo "import math; print(int(math.ceil(($AREA / ($NAND_AREA / $NANDS)))))" | python3` ;\
FREQ=`echo "print('{0:.5g}'.format(1e6/((-1 * $SLACK ) + $PER )))" | python3` ;\
echo "$AREA & $GATES & $FFS & $FREQ \\\\ \\hline"  > $RES
