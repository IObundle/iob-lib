#!/usr/bin/python3
'''
 Verilog2Tex: extract user guide documentation from Verilog sources
'''
import sys
import os
from parse import parse

'''
Parse header files
'''
def header_parse (vh, defines):

    for line in vh:
        d_flds = parse('`define {} {}\n', line.lstrip(' '))

        if d_flds is None:
            continue #not a macro

        #NAME
        name = d_flds[0].lstrip(' ')

        #VALUE
        eval_str = d_flds[1].strip('`').lstrip(' ').replace("$", "") #to replace $clog2 with clog2
        for key, val in defines.items():
            eval_str = eval_str.replace(str(key),str(val))

        try:
            value = eval(eval_str)
        except:
            #eval_str has undefined parameters: use as is
            value = eval_str

        #insert in dictionary
        if name not in defines:
            defines[name] = value

'''
Write Latex table
'''
            
def write_table(outfile, table):
    fout = open (outfile+'_tab.tex', 'w')
    for i in range(len(table)):
        if ((i%2) != 0): fout.write("\\rowcolor{iob-blue}\n")
        line = table[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout.write(line_out + ' \\\ \hline\n')

    fout.close()
    return


'''
Write Latex description
'''
            
def write_description(outfile, text):
    fout = open (outfile+'_desc.tex', 'w')
    for line in text:
        fout.write('\item['+line[0]+'] '+'{'+line[1]+'}\n')
    fout.close()

'''
Parse top-level parameters and macros
'''
    
def param_parse (topv, param_defaults, defines):

    param_defaults.update(defines)
    
    params = []
    macros = []

    for line in topv:
        p_flds = []
        p_flds_tmp = parse('{}parameter {} = {}//{}&{}&{}&{}', line)
        #spc, name, typ, macroparam, min, max, desc
        if p_flds_tmp is None:
            continue #not a parameter or macro

        #NAME 
        p_flds.append(p_flds_tmp[1].replace('_','\_').strip(' '))

        #MINIMUM VALUE
        #may be defined using macros: replace and evaluate
        eval_str = p_flds_tmp[4].replace('`','').replace(',','')

        for key, val in param_defaults.items():
            eval_str = eval_str.replace(str(key),str(val))
        try:
            p_flds.append(eval(eval_exp))
        except:
            #eval_str has undefined parameters: use as is
            p_flds.append(eval_str.replace('_','\_').strip(' '))
                
        #DEFAULT VALUE
        #may be defined using macros: replace and evaluate
        eval_str = p_flds_tmp[2].replace('`','').replace(',','')

        for key, val in param_defaults.items():
            eval_str = eval_str.replace(str(key),str(val))
        try:
            p_flds.append(eval(eval_exp))
        except:
            #eval_str has undefined parameters: use as is
            p_flds.append(eval_str.replace('_','\_').strip(' '))
                
        #MAXIMUM VALUE
        #may be defined using macros: replace and evaluate
        eval_str = p_flds_tmp[5].replace('`','').replace(',','')

        for key, val in param_defaults.items():
            eval_str = eval_str.replace(str(key),str(val))
        try:
            p_flds.append(eval(eval_exp))
        except:
            #eval_str has undefined parameters: use as is
            p_flds.append(eval_str.replace('_','\_').strip(' '))
                
        #DESCRIPTION
        if p_flds_tmp[3].find('PARAM')>=0:
            p_flds.append(p_flds_tmp[6].replace('_','\_').strip('PARAM'))
            params.append(p_flds)
        else:
            p_flds.append(p_flds_tmp[6].replace('_','\_').strip('MACRO'))
            macros.append(p_flds)
     
    #write out params
    if params != []:
        write_table("sp", params)

    #write out macros
    if macros != []:
        write_table("sm", macros)



'''
Parse block diagram modules
'''

def block_parse (block):

    b_list = []
    
    for line in block :
        b_flds = []
        b_flds_tmp = parse('{}//BLOCK {} & {}\n', line)
        if b_flds_tmp is None:
            b_flds_tmp = parse('//BLOCK {} & {}\n', line)
            if b_flds_tmp is None: continue #not a block
        else:
            b_flds_tmp = b_flds_tmp[1:]

        #NAME 
        b_flds.append(b_flds_tmp[0].replace('_','\_').strip(' '))

        #DESCRIPTION
        b_flds.append(b_flds_tmp[1].replace('_','\_'))

        b_list.append(b_flds)

    write_description("bd", b_list)

def io_parse (io_lines, defines):

    table_found = 0
    table_name = ''
    table = []

    for line in io_lines:

        #find table start
        if '//START_IO_TABLE' in line:
            if table_found == 1:
                write_table(table_name + '_if', table)
                table = []
            table_found = 1
            table_name = line.split()[1]
            continue

        io_flds = []
        io_flds_tmp = parse('{}`{}({},{}){}//{}', line)

        if io_flds_tmp is None or 'PUT' not in io_flds_tmp[1]:
            continue #not an io

        #NAME
        io_flds.append(io_flds_tmp[2].replace('_','\_').strip(' '))

        #TYPE
        io_flds.append(io_flds_tmp[1].replace('_VAR','').replace('IOB_','').strip(' '))

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
            
        table.append(io_flds)

    #write last table
    if table_found == 1:
        write_table(table_name + '_if', table)

        
def swreg_parse (vh, defines) :

    swreg_cnt = 0
    table_found = 0
    table = []

    for line in vh:

        #find table start
        if '//START_SWREG_TABLE' in line:
            if table_found == 1:
                write_table(table_name + '_swreg', table)
                table = [] #clear table
            table_found = 1
            flds = line.split()
            table_name = flds[1]
            continue

        swreg_flds = []
        swreg_flds_tmp = parse('{}`IOB_SWREG_{}({},{},{}){}//{}', line)

        if swreg_flds_tmp is None:
            swreg_flds_tmp = parse('`IOB_SWREG_{}({},{},{}){}//{}', line)
            if swreg_flds_tmp is None: continue #not a sw reg
        else:
            swreg_flds_tmp = swreg_flds_tmp[1:]

        #NAME
        swreg_flds.append(swreg_flds_tmp[1].replace('_','\_').strip(' '))

        #TYPE
        swreg_flds.append(swreg_flds_tmp[0])

        #ADDRESS
        swreg_flds.append(4*swreg_cnt)
        swreg_cnt = swreg_cnt + 1        
        
        #WIDTH
        #may be defined using macros: replace and evaluate
        eval_str = swreg_flds_tmp[2].replace('`','').replace(',','')
        for key, val in defines.items():
            eval_str = eval_str.replace(str(key),str(val))
        try:
            swreg_flds.append(eval(eval_str))
        except:
            #eval_str has undefined parameters: use as is
            swreg_flds.append(eval_str.replace('_','\_').strip(' '))

        #DEFAULT VALUE
        swreg_flds.append(swreg_flds_tmp[3])

        #DESCRIPTION
        swreg_flds.append(swreg_flds_tmp[5].replace('_','\_'))
            
        table.append(swreg_flds)

    #write last table
    if table_found == 1:
        write_table(table_name + '_swreg', table)

      
def main () :
    #parse command line
    if len(sys.argv) < 2:
        print("Usage: param2tex.py path/to/top_level.v [vh_files] [v_files]")
        print("vh_files: paths to .vh files used to extract macro values")
        print("v_files: paths to .v files used to extract blocks info")
        exit()

    #top-level verilog file
    topv = sys.argv[1]
    #macro dictionary
    defines = {}

    
    #read top-level Verilog file
    fv =  open (topv, 'r')
    topv_lines = fv.readlines()
    fv.close()

    vh = [] #header list
    v = [] #source list

    if(len(sys.argv) > 2):
        #read header files
        i=2
        while i<len(sys.argv) and sys.argv[i].find('.vh'):
            fvh =  open (sys.argv[i], 'r')
            vh = [*vh, *fvh.readlines()]
            fvh.close()
            i = i+1

        #parse headers if any
        if(i > 2): header_parse(vh, defines)

        #read source files
        while i<len(sys.argv):
            fv =  open (sys.argv[i], 'r')
            v = [*v *fv.readlines()]
            fv.close()
            i = i+1
            

    #PARSE TOP-LEVEL PARAMETERS AND MACROS

    #get the DEFINE environment variable
    param_defaults = {}
    DEFINE = os.getenv('DEFINE')
    print(DEFINE)
    if DEFINE is not None:
        DEFINE = DEFINE.split()
        #store param defaults in dictionary
        for i in range(len(DEFINE)):
            MACRO=DEFINE[i].split('=')
            param_defaults[MACRO[0]]=eval(MACRO[1])

    param_parse (topv_lines, param_defaults, defines)

    #PARSE BLOCK DIAGRAM MODULES
    block_parse([*topv_lines, *v])

    #PARSE INTERFACE SIGNALS
    io_parse ([*topv_lines, *vh], defines)

    #PARSE SOFTWARE ACCESSIBLE REGISTERS
    swreg_parse (vh, defines)
    
if __name__ == "__main__" : main ()
