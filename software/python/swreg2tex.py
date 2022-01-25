#!/usr/bin/python3
#
#    Build Latex tables of verilog module interface signals and registers
#

import sys
import os.path
import re
import string
import math

from vhparser import header_parse

def write_table(outfile, program):
    #write output file
    fout = open (outfile, 'w')
    for i in range(len(program)):
        if ((i%2) != 0): fout.write("\\rowcolor{iob-blue}\n")
        line = program[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout.write(line_out + ' \\\ \hline\n')

    fout.close()
    return


def swreg_parse (program, defines) :
    swreg_cnt = 0
    tables_dict = {}
    for line in program :
        if line.startswith("//`SWREG"): continue #commented SWREG line
            
        subline = re.sub('\[|\]|:|,|//|\;',' ', line)
        subline = re.sub('\(',' ',subline, 1)
        subline = re.sub('\)',' ', subline, 1)

        flds = subline.split()
        if not flds : continue #empty line
        #print flds[0]
        if ('START_TABLE' in flds[0]):
            table_name = flds[1]
            table_swregs = []
            tables_dict.update({table_name:table_swregs})
        elif ('SWREG_' in flds[0]): #software accessible registers
            tables_dict[table_name].append(flds)
            swreg_cnt = swreg_cnt + 1
        else: continue #not a recognized macro

    #generate software accessible register table
    if tables_dict:
        #print(tables_dict)
        addr_w = int(math.ceil(math.log(swreg_cnt*4)/math.log(2)/4))
        swreg_addr = 0
        for table_name, swreg_list in reversed(list(tables_dict.items())):
            program_out = []
            for flds in swreg_list:
                flds_out = ['','','','','','']
                flds_out[0] = re.sub('_','\_', flds[1]) #register name

                #register direction
                if '_RW' in flds[0]:
                    flds_out[1] = 'R/W'
                elif '_W' in flds[0]:
                    flds_out[1] = 'W'
                elif '_BANKR' in flds[0]:
                    flds_out[1] = 'R'
                elif '_BANKW' in flds[0]:
                    flds_out[1] = 'W'
                else:
                    flds_out[1] = 'R'

                flds_out[2] = ("0x{:0" + str(addr_w) + "x}").format(swreg_addr) #register addr
                
                if '_BANK' in flds[0]:
                    swreg_addr = swreg_addr + int(flds[4])/4
                else:
                    swreg_addr = swreg_addr+4
                for key, val in defines.items():
                    if key in str(flds[2]):
                        flds[2] = eval(re.sub(str(key),str(val), flds[2]))

                if '_BANK' in flds[0]:
                    if flds[2].isdigit():
                        flds_out[3] = str(int(flds[2])*int(flds[4])-1) + ":0" #register width
                    else:
                        flds_out[3] = re.sub('_', '\_', '('+str(flds[2]))+'*'+str(flds[4])+')'+ "-1:0" #register width 
                else:
                    if flds[2].isdigit():
                        flds_out[3] = str(int(flds[2])-1) + ":0" #register width
                    else:
                        flds_out[3] = re.sub('_', '\_', str(flds[2])) + "-1:0" #register width

                flds_out[4] = flds[3] #reset value
                if '_BANK' in flds[0]:
                    flds_out[5] = re.sub('_','\_', " ".join(flds[5:])) #register description4
                else:
                    flds_out[5] = re.sub('_','\_', " ".join(flds[4:])) #register description

                program_out.append(flds_out)

            write_table(str(table_name) + '_tab.tex', program_out)

    return

def main () :
    #parse command line
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        print("Usage: ./swreg2tex.py infile [header_file]")
        quit()
    else:
        infile = sys.argv[1]
        if len(sys.argv) == 3:
            vhfile = sys.argv[2]
        pass

    defines = {}
    if 'vhfile' in locals():
        #Create header dictionary
        defines = header_parse(vhfile)
        
    #parse input file
    fin = open (infile, 'r')
    program = fin.readlines()
    fin.close()
    swreg_parse (program, defines)

    #print program
    #for line in range(len(program)):
     #   print program[line]

if __name__ == "__main__" : main ()
