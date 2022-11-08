#!/usr/bin/env python3
'''Verilog2Tex: extract user guide documentation from Verilog sources and
        register configuration file (mkregs.toml)

   Usage: verilog2tex.py path/to/top_level.v [verilog_files] [mkregs.toml]
        print("verilog_files: paths to .v and .vh files
        print("mkregs_conf: path/to/mkregs.toml
'''
import sys
from parse import parse, search

from mkregs import calc_swreg_addr
import re
import tomli
from math import ceil


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
        # p_flds_tmp = parse('{}parameter {} = {}//{}&{}&{}&{}', line)
        result = search('{wspace}parameter {name} = {default_value}//{macroparam}&{min}&{max}&{description}\n', line)
        #spc, name, typ, macroparam, min, max, desc
        if result is None:
            continue #not a parameter or macro
        else:
            p_flds_tmp = result.named
            # Remove whitespace
            for key in p_flds_tmp:
                p_flds_tmp[key] = p_flds_tmp[key].strip(" ").strip("\t")
            
        #NAME
        p_flds.append(p_flds_tmp['name'].replace('_','\_'))

        #MINIMUM VALUE
        #may be defined using macros: replace and evaluate
        eval_str = p_flds_tmp['min'].replace('`','').replace(',','')

        for key, val in param_defaults.items():
            eval_str = eval_str.replace(str(key),str(val))
        try:
            p_flds.append(eval(eval_exp))
        except:
            #eval_str has undefined parameters: use as is
            p_flds.append(eval_str.replace('_','\_'))

        #DEFAULT VALUE
        #may be defined using macros: replace and evaluate
        eval_str = p_flds_tmp['default_value'].replace('`','').replace(',','').replace("$","")

        eval_str = str(param_defaults.get(eval_str.strip()))
        
        try:
            p_flds.append(eval(eval_str))
        except:
            #eval_str has undefined parameters: use as is
            p_flds.append(eval_str.replace('_','\_'))

        #MAXIMUM VALUE
        #may be defined using macros: replace and evaluate
        eval_str = p_flds_tmp['max'].replace('`','').replace(',','')
        for key, val in param_defaults.items():
            eval_str = eval_str.replace(str(key),str(val))
        try:
            p_flds.append(eval(eval_exp))
        except:
            #eval_str has undefined parameters: use as is
            p_flds.append(eval_str.replace('_','\_'))

        #DESCRIPTION
        if p_flds_tmp['macroparam'].find('PARAM')>=0:
            p_flds.append(p_flds_tmp['description'].replace('_','\_').strip('PARAM'))
            params.append(p_flds)
        else:
            p_flds.append(p_flds_tmp['description'].replace('_','\_').strip('MACRO'))
            macros.append(p_flds)
    
    #write out params
    if params != []:
        write_table("sp", params)

    #write out macros
    if macros != []:
        write_table("sm", macros)

    return params

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

def io_parse (io_lines, params, defines):

    table_found = 0
    table_name = ''
    table = []

    #extract param names to list
    param_names = []
    for param_idx in range(len(params)):
        param_names.append(params[param_idx][0].replace('\\',''))

    #parse each interface signal 
    for line in io_lines:
        #find table start
        if '//START_IO_TABLE' in line:
            if table_found == 1:
                write_table(table_name + '_if', table)
                table = []
            table_found = 1
            table_name = line.split()[1]
            continue

        # skip lines without V2TEX_IO
        if not 'V2TEX_IO' in line:
            continue

        io_flds = []
        result = search('{wspace}`IOB_{type}({name},{width}){wspace2}//V2TEX_IO{description}\n', line)
        if result is None:
            continue # not an input/output
        else:
            io_flds_tmp = result.named
            # remove whitespace
            for key in io_flds_tmp:
                io_flds_tmp[key] = io_flds_tmp[key].strip(" ").strip("\t")

        #NAME
        io_flds.append(io_flds_tmp['name'].replace('_','\_'))

        #TYPE
        io_flds.append(io_flds_tmp['type'].replace('_VAR',''))

        #WIDTH
        #may be defined using macros: replace and evaluate
        eval_str = io_flds_tmp['width'].replace('`','').replace(',','').replace('(','')
        
        try:
            io_flds.append(eval(eval_str))
        except:
            #eval_str has undefined parameters: use as is
            io_flds.append(eval_str.replace('_','\_'))

        #DESCRIPTION
        io_flds.append(io_flds_tmp['description'].replace('_','\_'))

        table.append(io_flds)

    #write last table
    if table_found == 1:
        write_table(table_name + '_if', table)


def get_swreg_by_name(swreg_list, name):
    for swreg in swreg_list:
        if 'name' in swreg and swreg['name'] == name:
            return swreg
    return None

#nbytes may be defined using macros: replace and evaluate
def replace_width_macro(nbytes,defines):
    tmp_width = f"{int(nbytes)*8}"
    eval_str = tmp_width.replace('`','').replace(',','')
    for key, val in defines.items():
        eval_str = eval_str.replace(str(key),str(val))
    try:
        return eval(eval_str)
    except:
        #eval_str has undefined parameters: use as is
        return eval_str.replace('_','\_').strip(' ')

def swreg_parse (toml_dict, defines) :

    table = []
    table_names = []
    for table_name, regs in toml_dict.items():
        table_names.append(table_name)
        for reg in regs[0].items():
            table.append({"tablename":table_name, "name":reg[0], "nbytes":ceil(int(reg[1]['nbits'])/8)} | reg[1])

    # calculate address field
    table = calc_swreg_addr(table)

    for table_name in table_names:
        #nbytes cannot contain macros because it is automatically calculated above, from the nbits field.
        #table_list = [[a['name'],a['rw_type'],a['addr'],replace_width_macro(a['nbytes'],defines),a['rst_val'],a['description']]\
        table_list = [[a['name'],a['rw_type'],a['addr'],a['nbytes']*8,a['rst_val'],a['description']]\
                        for a in table if a["tablename"] == table_name]
        # Escape underscores in register names and descriptions
        for a in table_list:
            a[0]=a[0].replace('_','\_') # Register name at index 0 of list
            a[5]=a[5].replace('_','\_') # Register description at index 5 of list
        write_table(table_name + '_swreg', table_list)
        
def header_parse(vh, defines):
    """ Parse header files
    """
    for line in vh:
        d_flds = parse('`define {} {}\n', line.lstrip(' '))
        if d_flds is None:
            continue  # not a macro
        # NAME
        name = d_flds[0].lstrip(' ')
        # VALUE
        eval_str = d_flds[1].replace('`', '').lstrip(' ').replace("$", "")
        # split string into alphanumeric words
        existing_define_candidates = re.split('\W+', eval_str)
        for define_candidate in existing_define_candidates:
            if defines.get(define_candidate):
                eval_str = eval_str.replace(str(define_candidate), str(defines[define_candidate]))
        try:
            value = eval(eval_str)
        except (ValueError, SyntaxError, NameError):
            # eval_str has undefined parameters: use as is
            value = eval_str
        # insert in dictionary
        if name not in defines:
            defines[name] = value


def main () :
    #parse command line
    if len(sys.argv) < 2:
        print("Usage: verilog2tex.py top [verilog_files] [conf]")
        print("top: top-level verilog file")
        print("verilog_files: list of .v and .vh files")
        print("conf: mkregs.toml file")
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
    toml_dict = {} # mkregs.toml dictionary

    if(len(sys.argv) > 2):

        #read and parse header files if any
        for arg in sys.argv:
            if arg.endswith('.vh'):
                fvh =  open (arg, 'r')
                vh = [*vh, *fvh.readlines()]
                fvh.close()
        header_parse(vh, defines)

        #read source files
        for arg in sys.argv:
            if arg.endswith('.v'):
                fv =  open (arg, 'r')
                v = [*v, *fv.readlines()]
                fv.close()

        # read mkregs.toml file
        conf_idx = len(sys.argv)-1
        if sys.argv[conf_idx] == 'mkregs.toml':
            fconf =  open (sys.argv[conf_idx], 'rb')
            toml_dict = tomli.load(fconf)
            fconf.close()



    #PARSE TOP-LEVEL PARAMETERS AND MACROS

    #get the DEFINE environment variable (deprecated)
    param_defaults = {}
    params = param_parse (topv_lines, param_defaults, defines)

    #PARSE BLOCK DIAGRAM MODULES
    block_parse([*v])

    #PARSE INTERFACE SIGNALS
    io_parse ([*topv_lines, *vh], params, defines)

    #PARSE SOFTWARE ACCESSIBLE REGISTERS
    if toml_dict != {}:
        swreg_parse (toml_dict, defines)

if __name__ == "__main__" : main ()
