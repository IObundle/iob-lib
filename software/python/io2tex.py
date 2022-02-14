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
    io_out = []
    io_list = []
    io_flds = []
    for line in verilog:
        print(line)
        io_flds = parse('`{}({},{}),{}', line)
        if line.find('INPUT')>=0:
            print (line)
            print (io_flds)
        if io_flds is None:
            continue #not an io
        else:            
            print("bla")
            io_type = io_flds[0].replace('_VAR','').strip(' ')
            io_flds[0] = io_flds[1].strip(' ') #io name
            io_flds[1] = io_type

            #io width
            #may be defined using macros: replace and evaluate
            for key, val in defines.items():
                if key in io_flds[2]:
                    io_flds[2] = io_flds[2].replace(str(key),str(val))
            #may be defined using parameters: beware of '_'
            io_flds[2] = io_flds[2].replace('_', '\_').strip(' ')

            io_flds[3] = io_flds[2].strip('//').strip(' ')  #io description
        
        io_list.append(io_flds)

    #print(io_list)
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
