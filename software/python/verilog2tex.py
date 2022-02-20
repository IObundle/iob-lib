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
    #write output file
    fout = open (outfile, 'w')
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
    #write output file
    fout = open (outfile, 'w')
    for line in text:
        fout.write('\item['+line[0]+'] '+'{'+line[1]+'}\n')
    fout.close()

'''
Parse top-level parameters and macros
'''
    
def param_parse (topv, param_defaults, defines):

    defines.update(param_defaults)
    
    params = []
    macros = []

    for line in topv:
        p_flds = []
        p_flds_tmp = parse('{}parameter {} = {}//{}', line)
        if p_flds_tmp is None:
            continue #not a parameter or macro

        #NAME 
        p_flds.append(p_flds_tmp[1].replace('_','\_').strip(' '))

        #VALUE
        #may be defined using macros: replace and evaluate
        eval_str = p_flds_tmp[2].replace('`','').replace(',','')

        for key, val in defines.items():
            eval_str = eval_str.replace(str(key),str(val))
        try:
            p_flds.append(eval(eval_exp))
        except:
            #eval_str has undefined parameters: use as is
            p_flds.append(eval_str.replace('_','\_').strip(' '))
                
        #DESCRIPTION
        if p_flds_tmp[3].find('PARAM')>=0:
            is_param = 1;
            p_flds.append(p_flds_tmp[3].replace('_','\_').strip('PARAM'))
        else:
            is_param = 0
            p_flds.append(p_flds_tmp[3].replace('_','\_').strip('MACRO'))

        if is_param == 1:
            params.append(p_flds)
        else:
            macros.append(p_flds)
     
    #write out params
    write_table("sp_tab.tex", params)

    #write out macros
    write_table("sm_tab.tex", macros)



'''
Parse block diagram modules
'''

def block_parse (block):

    b_list = []
    
    for line in block :
        b_flds = []
        b_flds_tmp = parse('{}//BLOCK {} & {}\n', line)
        if b_flds_tmp is None:
            continue #not a block

        #NAME 
        b_flds.append(b_flds_tmp[1].replace('_','\_').strip(' '))

        #DESCRIPTION
        b_flds.append(b_flds_tmp[2].replace('_','\_'))    

        b_list.append(b_flds)

    write_description("bd_tab.tex", b_list)

def io_parse (io_lines, defines):

    table_found = 0
    table_lines = []
    table_name = ''    
    io_list = []

    for line in io_lines:

        #find table start
        if '//START_TABLE' in line:
            if table_found == 1:
                write_table(table_name + '_tab.tex', table_lines)
            table_found = 1
            flds = line.split()
            table_name = flds[1]
            continue

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

    #write last table
    if table_found == 1:
        write_table(table_name + '_tab.tex', table_lines)

        
def swreg_parse (vh, defines) :

    swreg_cnt = 0
    table_found = 0
    table_lines = []

    print(vh)
    
    for line in vh:

        #find table start
        if '//START_TABLE' in line:
            if table_found == 1:
                write_table(table_name + '_tab.tex', table_lines)
            table_found = 1
            flds = line.split()
            table_name = flds[1]
            continue

        swreg_flds = []
        swreg_flds_tmp = parse('{}`{}({},{},{}){}//{}', line)

        if swreg_flds_tmp is None:
            continue #not a sw reg

        swreg_cnt = swreg_cnt + 1

        #NAME
        swreg_flds.append(swreg_flds_tmp[2].replace('_','\_').strip(' '))

        #TYPE
        swreg_flds.append(swreg_flds_tmp[1])

        #WIDTH
        #may be defined using macros: replace and evaluate
        eval_str = swreg_flds_tmp[3].replace('`','').replace(',','')
        for key, val in defines.items():
            eval_str = eval_str.replace(str(key),str(val))
        try:
            swreg_flds.append(eval(eval_str))
        except:
            #eval_str has undefined parameters: use as is
            swreg_flds.append(eval_str.replace('_','\_').strip(' '))

        #DEFAULT VALUE
        swreg_flds.append(swreg_flds_tmp[4])

        #DESCRIPTION
        swreg_flds.append(swreg_flds_tmp[6].replace('_','\_'))
            
        swreg_list.append(swreg_flds)

        swreg_list.append(swreg_flds)

    #write last table
    if table_found == 1:
        write_table(table_name + '_tab.tex', table_lines)



        
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

    
    if(len(sys.argv) > 2):
        #read header files
        vh = []
        i=2
        while i<len(sys.argv) and sys.argv[i].find('.vh'):
            fvh =  open (sys.argv[i], 'r')
            vh = [*vh, *fvh.readlines()]
            fvh.close()
            i = i+1

        #parse headers
        header_parse(vh, defines)

        #read top-level Verilog file
        fv =  open (topv, 'r')
        topv_lines = fv.readlines()
        fv.close()

        #read source files
        v = []
        while i<len(sys.argv):
            fv =  open (sys.argv[i], 'r')
            v = [*v *fv.readlines()]
            fv.close()
            i = i+1
            

    #PARSE TOP-LEVEL PARAMETERS AND MACROS

    #get the DEFINE environment variable
    DEFINE = os.getenv('DEFINE')
    if DEFINE is not None:
        DEFINE = DEFINE.split()

    
    #store param defaults in dictionary
    param_defaults = {}
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
