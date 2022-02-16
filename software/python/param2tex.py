#!/usr/bin/python3

# create parameter and macro tables


import sys
from parse import parse

from vhparser import header_parse

def param_parse (verilog, defines):
    params = []
    macros = []

    for line in verilog:
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
     
    return [params, macros]

def main () :
    
    #parse command line
    if len(sys.argv) < 2:
        print("Usage: param2tex.py path/to/top_level.v [header_files]")
        print("header_files: paths to .vh files used to extract macro values")
        exit()


    infile = sys.argv[1]
    outfile_params = "sp_tab.tex"
    outfile_macros = "sm_tab.tex"

    #create macro dictionary
    defines = {}
    for i in sys.argv[1:]:
        header_parse(i, defines)
        
    #parse input file
    fin = open (infile, 'r')
    verilog = fin.readlines()
    [params, macros] = param_parse (verilog, defines)

    #write out params
    fout = open (outfile_params, 'w')
    for i in range(len(params)):
        if ((i%2) != 0): fout.write("\\rowcolor{iob-blue}\n")
        line = params[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout.write(line_out + ' \\\ \hline\n')

    #write out macros
    fout_macros = open (outfile_macros, 'w')
    for i in range(len(macros)):
        if ((i%2) != 0): fout_macros.write("\\rowcolor{iob-blue}\n")
        line = macros[i]
        line_out = str(line[0])
        for l in range(1,len(line)):
            line_out = line_out + (' & %s' % line[l])
        fout_macros.write(line_out + ' \\\ \hline\n')

if __name__ == "__main__" : main ()
