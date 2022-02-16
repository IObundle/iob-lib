#!/usr/bin/python3
#
#    Build Latex tables of verilog module interface signals
#

import sys
from parse import parse
from vhparser import header_parse

def io_parse (verilog, defines) :

    io_list = []

    for line in verilog:
        io_flds = []
        io_flds_tmp = parse('{}`{}({},{}){}//{}', line)
        if io_flds_tmp is None:
            continue #not an io

        #NAME
        io_flds.append(io_flds_tmp[2].replace('_','\_').strip(' '))

        #TYPE
        io_flds.append(io_flds_tmp[1].replace('_VAR','').strip(' '))

        #WIDTH
        #may be defined using macros: replace and evaluate
        eval_str = io_flds_tmp[3].replace('`','').replace(',','')
        for key, val in defines.items():
            eval_str = eval_str.replace(str(key),str(val))
        try:
            io_flds.append(eval(eval_str))
        except:
            #eval_str has undefined parameters: use as is
            io_flds.append(eval_str.replace('_','\_').strip(' '))
                
        #DESCRIPTION
        io_flds.append(io_flds_tmp[5].replace('_','\_'))
            
        io_list.append(io_flds)

    return io_list

def main () :
    #parse command line
    if len(sys.argv) < 3:
        print("Usage: ./io2tex.py infile outfile [header_files]")
        quit()

        
    infile = sys.argv[1]
    outfile = sys.argv[2]

    #create macro dictionary
    defines = {}
    for i in sys.argv[3:]:
        header_parse(i, defines)
    header_parse(infile, defines)
        
    #parse input file
    fin = open (infile, 'r')
    verilog = fin.readlines()
    io = io_parse (verilog, defines)

    #write output file
    fout = open (outfile, 'w')
    for i in range(len(io)):
        if ((i%2) != 0): fout.write("\\rowcolor{iob-blue}\n")
        line = io[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout.write(line_out + ' \\\ \hline\n')

if __name__ == "__main__" : main ()
