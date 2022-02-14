#!/usr/bin/python3
#
#    Build Latex tables of verilog module interface signals and registers
#

import sys
import os.path
import re

def block_parse (block) :
    block_out = []
    line_out = []
    
    for line in block :
        if line.find('//BLOCK') < 0: continue #not a block description
        line_out = line.replace( '//BLOCK', '')
        line_out = line_out.split('&')
        block_out.append("\\item["+ line_out[0] +":]{"+ line_out[1]+"}")

    return block_out

def main () :
    #parse command line
    if len(sys.argv) < 3:
        print("Usage: ./block2tex.py outfile [infiles]")
        exit()
    else:
        outfile = sys.argv[1]
        infiles = sys.argv[2:]
        pass

    #add input files
    block = []
    for infile in infiles:
        fin = open (infile, 'r')
        block.extend(fin.readlines())
        fin.close()
    
    #parse input files
    block = block_parse (block)

    #write output file
    fout = open (outfile, 'w')
    for i in range(len(block)):
        fout.write(str(block[i]))

    #Close output file
    fout.close()

if __name__ == "__main__" : main ()
