#!/usr/bin/env python3
"""Verilog2Tex: extract user guide documentation from Verilog sources and
        register configuration file (mkregs.toml)

   Usage: verilog2tex.py path/to/top_level.v [verilog_files] [mkregs.toml]
        print("verilog_files: paths to .v, .vs and .vh files
        print("mkregs_conf: path/to/mkregs.toml
"""
from parse import parse, search

from mkregs import compute_addr
import re
from math import ceil
from latex import write_table, write_description

"""
Parse top-level parameters and macros
"""


def param_parse(topv, param_defaults, defines):
    param_defaults.update(defines)

    params = []
    macros = []

    for line in topv:
        p_flds = []
        result = search(
            "{wspace}parameter {name} = {default_value}//{macroparam}&{min}&{max}&{description}\n",
            line,
        )
        # spc, name, typ, macroparam, min, max, desc
        if result is None:
            continue  # not a parameter or macro
        else:
            p_flds_tmp = result.named
            # Remove whitespace
            for key in p_flds_tmp:
                p_flds_tmp[key] = p_flds_tmp[key].strip(" ").strip("\t")

        # NAME
        p_flds.append(p_flds_tmp["name"].replace("_", "\_"))

        # MINIMUM VALUE
        # may be defined using macros: replace and evaluate
        eval_str = p_flds_tmp["min"].replace("`", "").replace(",", "")

        for key, val in param_defaults.items():
            eval_str = eval_str.replace(str(key), str(val))
        try:
            p_flds.append(eval(eval_exp))
        except:
            # eval_str has undefined parameters: use as is
            p_flds.append(eval_str.replace("_", "\_"))

        # DEFAULT VALUE
        # may be defined using macros: replace and evaluate
        eval_str = (
            p_flds_tmp["default_value"]
            .replace("`", "")
            .replace(",", "")
            .replace("$", "")
        )

        eval_str = str(param_defaults.get(eval_str.strip()))

        try:
            p_flds.append(eval(eval_str))
        except:
            # eval_str has undefined parameters: use as is
            p_flds.append(eval_str.replace("_", "\_"))

        # MAXIMUM VALUE
        # may be defined using macros: replace and evaluate
        eval_str = p_flds_tmp["max"].replace("`", "").replace(",", "")
        for key, val in param_defaults.items():
            eval_str = eval_str.replace(str(key), str(val))
        try:
            p_flds.append(eval(eval_exp))
        except:
            # eval_str has undefined parameters: use as is
            p_flds.append(eval_str.replace("_", "\_"))

        # DESCRIPTION
        if p_flds_tmp["macroparam"].find("PARAM") >= 0:
            p_flds.append(p_flds_tmp["description"].replace("_", "\_").strip("PARAM"))
            params.append(p_flds)
        else:
            p_flds.append(p_flds_tmp["description"].replace("_", "\_").strip("MACRO"))
            macros.append(p_flds)

    # write out params
    if params != []:
        write_table("sp", params)

    # write out macros
    if macros != []:
        write_table("sm", macros)

    return params


"""
Parse block diagram modules
"""


def block_parse(block):
    b_list = []

    for line in block:
        b_flds = []
        b_flds_tmp = parse("{}//BLOCK {} & {}\n", line)
        if b_flds_tmp is None:
            b_flds_tmp = parse("//BLOCK {} & {}\n", line)
            if b_flds_tmp is None:
                continue  # not a block
        else:
            b_flds_tmp = b_flds_tmp[1:]

        # NAME
        b_flds.append(b_flds_tmp[0].replace("_", "\_").strip(" "))

        # DESCRIPTION
        b_flds.append(b_flds_tmp[1].replace("_", "\_"))

        b_list.append(b_flds)

    write_description("bd", b_list)


def io_parse(io_lines, params, defines):
    table_found = 0
    table_name = ""
    table = []

    # extract param names to list
    param_names = []
    for param_idx in range(len(params)):
        param_names.append(params[param_idx][0].replace("\\", ""))

    # parse each interface signal
    for line in io_lines:
        # find table start
        if "//START_IO_TABLE" in line:
            if table_found == 1:
                write_table(table_name + "_if", table)
                table = []
            table_found = 1
            table_name = line.split()[1]
            continue

        # skip lines without V2TEX_IO
        if not "V2TEX_IO" in line:
            continue

        io_flds = []
        result = search(
            "{wspace}`IOB_{type}({name},{width}){wspace2}//V2TEX_IO{description}\n",
            line,
        )
        if result is None:
            continue  # not an input/output
        else:
            io_flds_tmp = result.named
            # remove whitespace
            for key in io_flds_tmp:
                io_flds_tmp[key] = io_flds_tmp[key].strip(" ").strip("\t")

        # NAME
        io_flds.append(io_flds_tmp["name"].replace("_", "\_"))

        # TYPE
        io_flds.append(io_flds_tmp["type"].replace("_VAR", ""))

        # WIDTH
        # may be defined using macros: replace and evaluate
        eval_str = (
            io_flds_tmp["width"].replace("`", "").replace(",", "").replace("(", "")
        )

        try:
            io_flds.append(eval(eval_str))
        except:
            # eval_str has undefined parameters: use as is
            io_flds.append(eval_str.replace("_", "\_"))

        # DESCRIPTION
        io_flds.append(io_flds_tmp["description"].replace("_", "\_"))

        table.append(io_flds)

    # write last table
    if table_found == 1:
        write_table(table_name + "_if", table)


def swreg_parse(pregs):
    table = []
    for i in range(len(pregs)):
        table.append(pregs[i]["regs"])

    print(table)

    # calculate address field
    table = compute_addr(table, True)

    print(len(table))

    for i in range(len(pregs)):
        write_table(pregs[i]["name"] + "_swreg", table)


def header_parse(vh, defines):
    """Parse header files"""
    for line in vh:
        d_flds = parse("`define {} {}\n", line.lstrip(" "))
        if d_flds is None:
            continue  # not a macro
        # NAME
        name = d_flds[0].lstrip(" ")
        # VALUE
        eval_str = d_flds[1].replace("`", "").lstrip(" ").replace("$", "")
        # split string into alphanumeric words
        existing_define_candidates = re.split("\W+", eval_str)
        for define_candidate in existing_define_candidates:
            if defines.get(define_candidate):
                eval_str = eval_str.replace(
                    str(define_candidate), str(defines[define_candidate])
                )
        try:
            value = eval(eval_str)
        except (ValueError, SyntaxError, NameError):
            # eval_str has undefined parameters: use as is
            value = eval_str
        # insert in dictionary
        if name not in defines:
            defines[name] = value


#
# Main
#


def verilog2tex(pregs, top, vh, v):
    # macro dictionary
    defines = {}

    # read top-level Verilog file
    fp = open(top, "r")
    top_lines = fp.readlines()
    fp.close()

    vh_lines = []  # header list
    v_lines = []  # source list

    # read and parse header files
    for f in vh:
        fp = open(f, "r")
        vh_lines += fp.readlines()
        fp.close()
    header_parse(vh_lines, defines)

    # read source files
    for f in v:
        fp = open(f, "r")
        v_lines += fp.readlines()
        fp.close()

    # PARSE TOP-LEVEL PARAMETERS AND MACROS

    # get the DEFINE environment variable (deprecated)
    param_defaults = {}
    params = param_parse(top_lines, param_defaults, defines)

    # PARSE BLOCK DIAGRAM MODULES
    block_parse(v_lines)

    # PARSE INTERFACE SIGNALS
    io_parse(top_lines + vh_lines, params, defines)

    # PARSE SOFTWARE ACCESSIBLE REGISTERS
    if pregs != []:
        swreg_parse(pregs)
