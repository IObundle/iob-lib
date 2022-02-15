#!/usr/bin/python3
#
#    Add defines from .vh to local dictionary
#

from parse import parse

def header_parse (vhfile, defines):

    f = open(vhfile, 'r')

    for line in f:
        d_flds = parse('{}`define {} {}', line)
        if d_flds is None:
            continue #not a macro

        #NAME
        name = d_flds[1].replace('_','\_').strip(' ').strip('`')

        #VALUE
        eval_str = d_flds[1].replace("$", "") #to replace $clog2 with clog2
        for key, val in defines.items():
            eval_str = eval_str.replace(str(key),str(val))

        try:
            value = eval(eval_exp)
        except:
            #eval_str has undefined parameters: quit
            print("ERROR: Macro cannot be defined using another undefined macro: %s", eval_str)

        #Write to dictionary
        for key, val in defines.items():
            if val:
                defines.update({key:int(val)})

    print (defines)
    f.close()
    
