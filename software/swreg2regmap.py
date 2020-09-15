#!/usr/bin/python2.7
#
#    Build Latex tables of verilog module interface signals and registers
#

import sys
import os.path
import re

def write_mapping(outfile, name_map, width_map, init_val_map, type_map):
    #write output file
    fout = open (outfile, 'w')
    
    fout.write("`define N_WREGS " + str(len(name_map)) + "\n")

    fout.write("\n//name mapping\n")
    for i in range(len(name_map)):
        fout.write("`define `NAME_REG(" + str(i) + ") " + str(name_map[i]) + "\n")

    fout.write("\n//width mapping\n")
    for i in range(len(width_map)):
        fout.write("`define `NAME_REG_W(" + str(i) + ") " + str(width_map[i]) + "\n")

    fout.write("\n//init val mapping\n")
    for i in range(len(init_val_map)):
        fout.write("`define `NAME_REG_INI(" + str(i) + ") " + str(init_val_map[i]) + "\n")

    fout.write("\n//type mapping\n")
    for i in range(len(type_map)):
        fout.write("`define `NAME_REG_TYP(" + str(i) + ") " + str(type_map[i]) + "\n")

    fout.close()
    return


def swreg_parse (program, outfile) :
    name_map = []
    width_map = []
    init_val_map = []
    type_map = []
    for line in program :
        subline = re.sub('\[|\]|:|,|//|\;',' ', line)
        subline = re.sub('\(',' ',subline, 1)
        subline = re.sub('\)',' ', subline, 1)

        flds = subline.split()
        if not flds : continue #empty line
        #print flds[0]
        if ('SWREG_' in flds[0]): #software accessible registers
            reg_name = flds[1] #register name
            reg_width = flds[2] #register width
            reg_init_val = flds[3] #register init val

            #register type
            if '_RW' in flds[0]:
                reg_type = '`RW_TYP'
            elif 'W' in flds[1]:
                reg_type = '`W_TYP'
            else:
                reg_type = '`R_TYP'


            name_map.append(reg_name)
            width_map.append(reg_width)
            init_val_map.append(reg_init_val)
            type_map.append(reg_type)
        else: continue #not a recognized macro

    write_mapping(outfile, name_map, width_map, init_val_map, type_map)
    return

def main () :
    #parse command line
    if len(sys.argv) != 3:
        vaError("Usage: ./v2tex.py infile outfile")
    else:
        infile = sys.argv[1]
        outfile = sys.argv[2]
        
    #parse input file
    fin = open (infile, 'r')
    program = fin.readlines()
    fin.close()
    swreg_parse (program, outfile)

if __name__ == "__main__" : main ()
