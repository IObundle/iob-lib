#!/bin/bash

set -e

#altera
if [ $INTEL = 1 ]; then \
LOG="quartus.log" ;\
RES="alt_results.tex" ;\
ALM=`grep ALM $LOG |grep -o '[0-9,]* \/' | sed s/'\/'//g` ;\
FF=`grep registers $LOG |grep -o '[0-9]*' | sed s/'\/'//g` ;\
DSP=`grep DSP $LOG |grep -o '[0-9]* \/' | sed s/'\/'//g` ;\
BRAM=`grep RAM $LOG |grep -o '[0-9]* \/' | sed s/'\/'//g` ;\
BRAMb=`grep 'block memory' $LOG |grep -o '[0-9,]* \/' | sed s/'\/'//g` ;\
PIN=`grep pin $LOG |grep -o '[0-9]* \/' | sed s/'\/'//g`;\
echo "ALM & $ALM \\\\ \\hline" > $RES ;\
echo "\rowcolor{iob-blue}"  >> $RES ;\
echo "FF & $FF  \\\\  \\hline"  >> $RES ;\
echo "DSP & $DSP \\\\ \\hline"  >> $RES ;\
echo "\rowcolor{iob-blue}"  >> $RES ;\
echo "BRAM blocks & $BRAM \\\\ \\hline"  >> $RES ;\
echo "BRAM bits & $BRAMb \\\\ \\hline"  >> $RES ;\
echo "\rowcolor{iob-blue}"  >> $RES ;\
#if [ "$PIN" ]; then \
#echo "PIN & $PIN \\\\ \\hline"  >> $RES ;\
#fi \
fi


#xilinx
if [ $XILINX = 1 ]; then \
LOG="vivado.log" ;\
RES="xil_results.tex" ;\
LUT=`grep -m1 -o 'LUTs\ *|\ * [0-9]*' vivado.log | sed s/'| L'/L/g | sed s/\|/'\&'/g` ;\
FF=`grep -m1 -o 'Registers\ *|\ * [0-9]*' vivado.log | sed s/'| L'/L/g | sed s/\|/'\&'/g` ;\
DSP=`grep -m1 -o 'DSPs\ *|\ * [0-9]*' vivado.log | sed s/'| L'/L/g | sed s/\|/'\&'/g` ;\
BRAM=`grep -m1 -o 'Block RAM Tile \ *|\ * [0-9.]*' vivado.log | sed s/'| L'/L/g | sed s/\|/'\&'/g | sed s/lock\ //g | sed s/Tile//g` ;\
PIN=`grep -m1 -o 'Bonded IOB\ *|\ * [0-9]*' vivado.log | sed s/'| L'/L/g | sed s/\|/'\&'/g | sed s/'Bonded IOB'/PIN/g` ;\
echo "$LUT \\\\ \\hline"  > $RES ;\
echo "\rowcolor{iob-blue}"  >> $RES ;\
echo "$FF  \\\\  \\hline" >> $RES ;\
echo "$DSP \\\\ \\hline" >> $RES ;\
echo "\rowcolor{iob-blue}" >> $RES ;\
echo "$BRAM \\\\ \\hline" >> $RES ;\
#if [ "$PIN" ]; then \
#echo "$PIN \\\\ \\hline" >> $RES ;\
#fi \
fi
