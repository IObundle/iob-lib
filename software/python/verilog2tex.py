#!/usr/bin/python3
'''
 Verilog2Tex: extract user guide documentation from Verilog sources
'''
import sys
from parse import parse

'''
Parse header files
'''
def header_parse (vh, defines):

    for line in vh:
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


'''
Parse top-level parameters and macros
'''
    
def param_parse (topv, defines):

    outfile_params = "sp_tab.tex"
    outfile_macros = "sm_tab.tex"

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
        #print(eval_str)
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
    fout = open (outfile_params, 'w')
    for i in range(len(params)):
        if ((i%2) != 0): fout.write("\\rowcolor{iob-blue}\n")
        line = params[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout.write(line_out + ' \\\ \hline\n')
        fout.close()
        
    #write out macros
    fout_macros = open (outfile_macros, 'w')
    for i in range(len(macros)):
        if ((i%2) != 0): fout_macros.write("\\rowcolor{iob-blue}\n")
        line = macros[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout_macros.write(line_out + ' \\\ \hline\n')
        fout_macros.close()

'''
Parse block diagram modules
'''

def block_parse (topv,v):

    block = topv.append(v)
    block_out = []
    line_out = []
    
    for line in block :
        if line.find('//BLOCK') < 0: continue #not a block description
        line_out = line.replace( '//BLOCK', '')
        line_out = line_out.split('&')
        block_out.append("\\item["+ line_out[0] +":]{"+ line_out[1]+"}")

    #write output file
    fout = open (outfile, 'w')
    for i in range(len(block)):
        fout.write(str(block[i]))

    #Close output file
    fout.close()

def io_parse (topv, vh, defines) :

    verilog = topv.append(vh)

    table_found = 0
    table_lines = []
    
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

    #write output file
    fout = open (outfile, 'w')
    for i in range(len(io)):
        if ((i%2) != 0): fout.write("\\rowcolor{iob-blue}\n")
        line = io[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout.write(line_out + ' \\\ \hline\n')

def swreg_parse (vh, defines) :

    swreg_cnt = 0
    table_found = 0
    table_lines = []
    
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
            #eval_str has undefined parameters: do not replace and use as is
            swreg_flds.append(eval_str.replace('_','\_').strip(' '))

        #DEFAULT VALUE
        swreg_flds.append(swreg_flds_tmp[4])

        #DESCRIPTION
        swreg_flds.append(swreg_flds_tmp[6].replace('_','\_'))
            
        swreg_list.append(swreg_flds)

        swreg_list.append(swreg_flds)

    #write output file
    fout = open (outfile, 'w')
    for i in range(len(io)):
        if ((i%2) != 0): fout.write("\\rowcolor{iob-blue}\n")
        line = io[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout.write(line_out + ' \\\ \hline\n')

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
            vh.append(fvh.readlines())
            fvh.close()
            i = i+1

        #parse headers
        header_parse(vh, defines)

        #read source files
        v = []
        while i<len(sys.argv) and sys.argv[i].find('.v'):
            fv =  open (sys.argv[i], 'r')
            v.append(fv.readlines())
            fv.close()
            i = i+1
            

    #parse top-level parameters and macros
    param_parse (topv, defines)

    #parse block diagram modules
    block_parse(topv, v)

    #parse inputs and outputs
    io_parse (topv, vh, defines)

    #parse software accessible registers
    swreg_parse (vh, defines)
    
if __name__ == "__main__" : main ()
