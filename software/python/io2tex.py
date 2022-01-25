#!/usr/bin/python2
#
#    Build Latex tables of verilog module interface signals and registers
#

import sys
import os.path
import re
import math

from vhparser import header_parse

def io_parse (program, defines) :
    program_out = []
    swreg_list = []
    for line in program :
        flds_out = ['','','','']
        subline = re.sub('\[|\]|:|,|//|\;',' ', line)
        subline = re.sub('\(',' ',subline, 1)
        subline = re.sub('\)',' ', subline, 1)

        flds = subline.split()
        if not flds : continue #empty line
        #print flds[0]
        if (flds[0] != '`INPUT') & (flds[0] != '`OUTPUT') & (flds[0] != '`INOUT'): continue #not IO
        #print flds
        flds_out[1] = re.sub('`','', flds[0]).lower() #signal direction

        flds_out[0] = re.sub('_','\_',flds[1]) #signal name
        if flds[2] in defines:#check for matching key first
            flds[2] = defines[flds[2]]
        else: #macro composed by multiple defines
            for key, val in defines.items():
                if key in str(flds[2]):
                    flds[2] = eval(re.sub(str(key),str(val), flds[2]))
                pass
        flds_out[2] = re.sub('_', '\_', str(flds[2]))  #signal width
        flds_out[3] = re.sub('_','\_'," ".join(flds[3:])) #signal description

        program_out.append(flds_out)

    return program_out

def main () :
    #parse command line
    if len(sys.argv) != 3 and len(sys.argv) != 4:
        print("Usage: ./io2tex.py infile [header_file]")
        quit()
    else:
        infile = sys.argv[1]
        outfile = sys.argv[2]
        if len(sys.argv) == 4:
            vhfile = sys.argv[3]
        pass

    defines = {}
    if 'vhfile' in locals():
        #Create header dictionary
        defines = header_parse(vhfile)
        
    #parse input file
    fin = open (infile, 'r')
    program = fin.readlines()
    program = io_parse (program, defines)

    #print program
    #for line in range(len(program)):
     #   print program[line]

    #write output file
    fout = open (outfile, 'w')
    for i in range(len(program)):
        if ((i%2) != 0): fout.write("\\rowcolor{iob-blue}\n")
        line = program[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout.write(line_out + ' \\\ \hline\n')

    #Close files
    fin.close()
    fout.close()

if __name__ == "__main__" : main ()
