#!/usr/bin/python3
#
#    Build Latex tables of verilog module interface signals and registers
#

import sys
import os.path
import math
from parse import parse

from vhparser import header_parse

def io_parse (verilog, defines) :
    io_list = []
    for line in verilog:
        io_flds = []
        io_flds_tmp = parse('{}`{}({},{}),{}//{}', line)
        if io_flds_tmp is None:
            continue #not an io
        else:            
            #io name
            io_flds.append(io_flds_tmp[2].replace('_','\_').strip(' '))
            #io type
            io_flds.append(io_flds_tmp[1].replace('_VAR','').strip(' '))
            #io width
            #may be defined using macros: replace and evaluate
            eval_str = io_flds_tmp[3]
            for key, val in defines.items():
                eval_str = eval_str.replace(str(key),str(val))
            try:
                io_flds.append(eval(eval_exp))
            except:
                #eval_str has undefined parameters: use as is
                io_flds.append(eval_str.replace('_','\_').strip(' '))
                
            #io description
            io_flds.append(io_flds_tmp[5].replace('_','\_'))
            
        io_list.append(io_flds)
    return io_list

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
    verilog = fin.readlines()
    io = io_parse (verilog, defines)

    #print ios
    #for line in range(len(io)):
     #   print io[line]

    #write output file
    fout = open (outfile, 'w')
    for i in range(len(io)):
        if ((i%2) != 0): fout.write("\\rowcolor{iob-blue}\n")
        line = io[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout.write(line_out + ' \\\ \hline\n')

    #Close files
    fin.close()
    fout.close()

if __name__ == "__main__" : main ()
