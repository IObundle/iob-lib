#!/usr/bin/python3
#
#  add macros from .vh files to a local dictionary
#

from parse import parse

def header_parse (vhfile, defines):

    f = open(vhfile, 'r')
    for line in f:
        d_flds = parse('`define {} {}\n', line.lstrip(' '))
        #print(line, d_flds)

        if d_flds is None:
            continue #not a macro

        #NAME
        name = d_flds[0].lstrip(' ')

        #VALUE
        eval_str = d_flds[1].strip('`').lstrip(' ').replace("$", "") #to replace $clog2 with clog2
        #print (eval_str)
        for key, val in defines.items():
            eval_str = eval_str.replace(str(key),str(val))

        try:
            value = eval(eval_str)
        except:
            #eval_str has undefined parameters: quit
            print("ERROR: Macro cannot be defined using another undefined macro:", eval_str)

        #insert in dictionary
        if name not in defines:
            defines[name] = value
        
    #print (defines)
    f.close()
    
