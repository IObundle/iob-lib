#!/usr/bin/python3
#
#    Build Latex tables of verilog module interface signals and registers
#

import sys
import os.path
import re

def block_parse (program) :
    program_out = []

    for line in program :
        flds_out = ['']
        subline = line

        flds = subline.split()
        if not flds : continue #empty line
        #print flds[0]
        if (flds[0] != '//BLOCK'): continue #not a block description
        #print flds

        flds_out[0] = re.sub('_','\_'," ".join(flds[1:])) + " \\vspace{2mm}" #block

        program_out.append(flds_out)

    return program_out

def main () :
    #parse command line
    if len(sys.argv) < 3:
        print("Usage: ./block2tex.py outfile [infiles]")
        exit()
    else:
        outfile = sys.argv[1]
        infiles = sys.argv[2:]
        pass

    print(sys.argv)
    #add input files
    program = []
    for infile in infiles:
        fin = open (infile, 'r')
        program.extend(fin.readlines())
        fin.close()
    
    #parse input files
    program = block_parse (program)

    #write output file
    fout = open (outfile, 'w')
    for i in range(len(program)):
        if ((i%2) != 0): fout.write("\\rowcolor{iob-blue}\n")
        line = program[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout.write(line_out + ' \\\ \hline\n')

    #Close output file
    fout.close()

if __name__ == "__main__" : main ()
