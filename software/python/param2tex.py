#!/usr/bin/python2
#
#    Build Latex tables of verilog module interface signals and registers
#

import sys
import os.path
import re

from vhparser import header_parse

def param_parse (program, vhfile) :
    defines = {}
    if 'vhfile' in locals():
        #Creates header dictionary
        defines = header_parse(vhfile)

    params = []
    macros = []

    for line in program :
        flds_out = ['', '', '']
        subline = re.sub('//',' ', line)
        subline = re.sub('=', '', subline, 1)

        flds = subline.split()
        if not flds : continue #empty line
        #print flds[0]
        if (flds[0] != 'parameter'): continue #not a block description
        #print flds
        param_desc = str(re.sub('_','\_', " ".join(flds[3:])))
        if param_desc.startswith("PARAM"):
            params.append(flds_out)
            param_desc =  param_desc[len("PARAM "):]
        elif param_desc.startswith("MACRO"):
            macros.append(flds_out)
            param_desc =  param_desc[len("MACRO "):]
        else:
            continue #undocummented parameter
           
        flds_out[0] = re.sub('_','\_', flds[1]) #parameter name
        flds[2] = re.sub(',', '', str(flds[2]))

        if flds[2].isdigit():
            flds_out[1] = re.sub('_', '\_', re.sub(',', '', flds[2])) #parameter value
        else:
            for key in defines:
                if key in str(flds[2]):
                    flds[2] = eval(re.sub(str(key), str(defines[key]), flds[2]))
            flds_out[1] = re.sub('_', '\_', str(flds[2])) #parameter value
        flds_out[2] = "\\noindent\parbox[c]{\hsize}{\\rule{0pt}{15pt} " + str(param_desc) + " \\vspace{2mm}}" #parameter description

 
    return [params, macros]

def main () :
    #parse command line
    if len(sys.argv) != 4 and len(sys.argv) != 5:
        print(len(sys.argv))
        print("Usage: ./param2tex.py infile outfile_params outfile_macros [header_file]")
        print("infile is the top-level .v file, where the synthesis parameters are defined")
        print("outfile_params is the .tex file, where the synthesis parameters are tabulated")
        print("outfile_macros is the .tex file, where the synthesis macros are tabulated")
        print("header_file is a .vh file with definitions of the macros used in infile")
        exit()
    else:
        infile = sys.argv[1]
        outfile = sys.argv[2]
        outfile_macros = sys.argv[3]
        if len(sys.argv) == 5:
            vhfile = sys.argv[4]
        pass

    #parse input file
    fin = open (infile, 'r')
    program = fin.readlines()
    [program, macros] = param_parse (program, vhfile)

    #write output file
    fout = open (outfile, 'w')
    for i in range(len(program)):
        if ((i%2) != 0): fout.write("\\rowcolor{iob-blue}\n")
        line = program[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout.write(line_out + ' \\\ \hline\n')

    #write output file for macros
    fout_macros = open (outfile_macros, 'w')
    for i in range(len(macros)):
        if ((i%2) != 0): fout_macros.write("\\rowcolor{iob-blue}\n")
        line = macros[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout_macros.write(line_out + ' \\\ \hline\n')

    #Close files
    fin.close()
    fout.close()
    fout_macros.close()

if __name__ == "__main__" : main ()
