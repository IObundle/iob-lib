#!/usr/bin/env python3
#
#    mkregs.py: build Verilog software accessible registers and software getters and setters
#

import sys
import argparse
from parse import parse, search
import math

cpu_nbytes = 4
core_addr_w = None

def parse_arguments():
    help_str = """
    mkregs.conf file:
        The configuration file supports the following formats:
            IOB_SWREG_R(NAME, NBITS, RST_VAL, ADDR, ADDR_W, AUTOLOGIC) // Description
            IOB_SWREG_W(NAME, NBITS, RST_VAL, ADDR, ADDR_W, AUTOLOGIC) // Description
    """

    parser = argparse.ArgumentParser(
            description="mkregs.py script generates hardware logic and bare-metal software drivers to interface core with CPU.",
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog=help_str
            )

    parser.add_argument("TOP", help="""Top/core module name""")
    parser.add_argument("PATH", help="""Path to mkregs.conf file""")
    parser.add_argument("hwsw", choices=['HW', 'SW'],
                        help="""HW: generate the hardware files
                        SW: generate the software files"""
                        )
    parser.add_argument("vh_files", 
                        nargs='*',
                        help="""paths to .vh files used to import HW macros to SW macros"""
                        )

    return parser.parse_args()

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

def gen_wr_reg(row, f):
    reg = row['name']
    reg_w = row['nbits']
    byte_offset = row['addr'] % 4
    reg_addr_w = row['addr_w']
    reg_word_addr = math.floor(row['addr']/cpu_nbytes)
    f.write(f"\n`IOB_WIRE({reg}_wen, 1)\n")
    f.write(f"assign {reg}_wen = valid_i & (|wstrb_i[{byte_offset}+:{row['nbytes']}]) & ((addr_i>>2) == {(reg_word_addr>>2)});\n")
    f.write(f"`IOB_WIRE({reg}_wdata, {reg_w})\n")
    f.write(f"assign {reg}_wdata = wdata_i[{8*byte_offset}+:{reg_w}];\n")
    if row['autologic']:
        f.write(f"`IOB_WIRE({reg}_ready_i, 1)\n")
        f.write(f"assign {reg}_ready_i = |wstrb_i;\n")
        f.write(f"iob_reg #({reg_w},0) {reg}_datareg (clk_i, rst_i, 1'b0, {reg}_wen, {reg}_wdata, {reg}_o);\n")
    else:
        f.write(f"assign {reg}_o = {reg}_wdata;\n")
    if row['addr_w'] > cpu_nbytes:
        f.write(f"assign {reg}_addr_o = addr_i[{reg_addr_w}-1:0];\n")
        
def gen_rd_reg(row, f):
    reg = row['name']
    reg_w = row['nbits']
    reg_addr_w = row['addr_w']
    reg_word_addr = math.floor(row['addr']/cpu_nbytes)
    f.write(f"\n`IOB_WIRE({reg}_ren, 1)\n")
    f.write(f"assign {reg}_ren = valid_i & ( addr_i == {reg_word_addr} ) & ~(|wstrb_i);\n")
    if row['autologic']:
        f.write(f"`IOB_WIRE({reg}_ready_i, 1)\n")
        f.write(f"assign {reg}_ready_i = !wstrb_i;\n")
        f.write(f"`IOB_WIRE({reg}_rvalid_i, 1)\n")
        f.write(f"iob_reg #(1,0) {reg}_rvalid (clk_i, rst_i, 1'b0, 1'b1, {reg}_ren, {reg}_rvalid_i);\n")
        f.write(f"`IOB_WIRE({reg}_r, {reg_w})\n")
        f.write(f"iob_reg #({reg_w},0) {reg}_datareg (clk_i, rst_i, 1'b0, {reg}_ren, {reg}_i, {reg}_r);\n")
        f.write(f"assign {reg}_int_o = {reg}_r;\n")
    else:
        f.write(f"assign {reg}_ren_o = {reg}_ren;\n")
    if row['addr_w'] > cpu_nbytes:
        f.write(f"assign {reg}_addr_o = addr_i[{reg_addr_w}-1:0];\n")
    
def gen_port(table, f):
    for row in table:
        reg = row['name']
        reg_w = row['nbits']
        reg_addr_w = row['addr_w']
        if row['rw_type'] == 'W':
            f.write(f"\t`IOB_OUTPUT({reg}_o, {reg_w}),\n")
            if not row['autologic']:
                f.write(f"\t`IOB_OUTPUT({reg}_wen_o, 1),\n")
        else:
            f.write(f"\t`IOB_INPUT({reg}_i, {reg_w}),\n")
            if not row['autologic']:
                f.write(f"\t`IOB_OUTPUT({reg}_ren_o, 1),\n")
                f.write(f"\t`IOB_INPUT({reg}_rvalid_i, 1),\n")
            else:
                f.write(f"\t`IOB_OUTPUT({reg}_int_o, {reg_w}),\n")
        if not row['autologic']:
            f.write(f"\t`IOB_INPUT({reg}_ready_i, 1),\n")
        if row['addr_w'] > cpu_nbytes:
            f.write(f"\t`IOB_OUTPUT({reg}_addr_o, {reg_addr_w}),\n")
        
def gen_inst_wire(table, f):
    for row in table:
        reg = row['name']
        reg_w = row['nbits']
        reg_addr_w = row['addr_w']
        if row['rw_type'] == 'W':
            f.write(f"`IOB_WIRE({reg}, {reg_w})\n")
            if not row['autologic']:
                f.write(f"`IOB_WIRE({reg}_wen, 1)\n")
        else:
            f.write(f"`IOB_WIRE({reg}, {reg_w})\n")
            if not row['autologic']:
                f.write(f"`IOB_WIRE({reg}_rvalid, 1)\n")
                f.write(f"`IOB_WIRE({reg}_ren, 1)\n")
            else:
                f.write(f"`IOB_WIRE({reg}_int, {reg_w})\n")
        if not row['autologic']:
            f.write(f"`IOB_WIRE({reg}_ready, 1)\n")
        if row['addr_w'] > cpu_nbytes:
            f.write(f"`IOB_WIRE({reg}_addr, {reg_addr_w})\n")
    f.write("\n")
            
        
def gen_portmap(table, f):
    for row in table:
        reg = row['name']
        if row['rw_type'] == 'W':
            f.write(f"\t.{reg}_o({reg}),\n")
            if not row['autologic']:
                f.write(f"\t.{reg}_wen_o({reg}_wen),\n")
        else:
            f.write(f"\t.{reg}_i({reg}),\n")
            if not row['autologic']:
                f.write(f"\t.{reg}_rvalid_i({reg}_rvalid),\n")
                f.write(f"\t.{reg}_ren_o({reg}_ren),\n")
            else:
                f.write(f"\t.{reg}_int_o({reg}_int),\n")
        if not row['autologic']:
            f.write(f"\t.{reg}_ready_i({reg}_ready),\n")
        if row['addr_w'] > cpu_nbytes:
            f.write(f"\t.{reg}_addr_o({reg}_addr),\n")
        
def write_hwcode(table, top):

    #
    #SWREG INSTANCE
    #
    
    fswreg_inst = open(f"{top}_swreg_inst.vh", "w")
    fswreg_inst.write("//This file was generated by script mkregs.py\n\n")

    #connection wires
    gen_inst_wire(table, fswreg_inst)

    fswreg_inst.write("swreg #(ADDR_W, DATA_W) swreg_inst (\n")
    gen_portmap(table, fswreg_inst)
    fswreg_inst.write('\t`include "iob_s_portmap.vh"\n')
    fswreg_inst.write('\t`include "iob_clkrst_portmap.vh"')
    fswreg_inst.write("\n);\n")

    #
    #SWREG MODULE
    #
    
    fswreg_gen = open(f"{top}_swreg_gen.v", "w")
    fswreg_gen.write("//This file was generated by script mkregs.py\n\n")

    #time scale
    fswreg_gen.write("`timescale 1ns / 1ps\n\n")

    #declaration
    fswreg_gen.write("module swreg\n")

    #parameters
    fswreg_gen.write("#(\n")
    fswreg_gen.write("\tparameter ADDR_W = 0,\n")
    fswreg_gen.write("\tparameter DATA_W = 0\n")
    fswreg_gen.write(")\n")
    fswreg_gen.write("(\n")

    #ports
    gen_port(table, fswreg_gen)
    fswreg_gen.write('\t`include "iob_s_port.vh"\n')
    fswreg_gen.write('\t`include "iob_clkrst_port.vh"\n')    
    fswreg_gen.write(");\n\n")

    #register logic
    has_addr_r = 0
    for row in table:
        if row['rw_type'] == 'W':
            #write register 
            gen_wr_reg(row, fswreg_gen)
        else:
            #read register 
            gen_rd_reg(row, fswreg_gen)
            #address register
            if not has_addr_r:
                has_addr_r = 1
                fswreg_gen.write("//address register\n")
                fswreg_gen.write(f"`IOB_WIRE(addr_r, {core_addr_w})\n")
                fswreg_gen.write(f"iob_reg #({core_addr_w}, 0) addr_r0 (clk_i, rst_i, 1'b0, valid_i, addr_i, addr_r);\n\n")

    #
    # COMBINATORIAL RESPONSE SWITCH
    #

    #use variables to compute response
    fswreg_gen.write(f"\n`IOB_VAR(rdata_int, {str(8*cpu_nbytes)})\n")
    fswreg_gen.write("`IOB_VAR(rvalid_int, 1)\n")
    fswreg_gen.write("`IOB_VAR(wready_int, 1)\n")
    fswreg_gen.write("`IOB_VAR(rready_int, 1)\n")
    fswreg_gen.write("`IOB_WIRE(ready_int, 1)\n\n")

    fswreg_gen.write("`IOB_COMB begin\n\n")

    #response defaults
    fswreg_gen.write("\twready_int = 1'b0;\n")
    fswreg_gen.write("\trready_int = 1'b0;\n")
    fswreg_gen.write("\trdata_int = 0;\n")
    fswreg_gen.write("\trvalid_int = 1'b0;\n\n")

    #update responses
    for row in table:
        reg = row['name']
        #compute rdata and rvalid
        if row['rw_type'] == 'R':
            #get rdata and rvalid
            fswreg_gen.write(f"\tif( (addr_r>>2) == ({row['addr']}>>2) )"+" begin\n")
            # get rdata
            if row['autologic']:
                fswreg_gen.write(f"\t\trdata_int = rdata_int | ({reg}_r << {8*row['addr']%4});\n")
            else:
                fswreg_gen.write(f"\t\trdata_int = rdata_int | ({reg}_i << {8*row['addr']%4});\n")
            # get rvalid
            fswreg_gen.write(f"\t\trvalid_int = rvalid_int | {reg}_rvalid_i;\n")
            fswreg_gen.write("\tend\n")
            #get rready
            fswreg_gen.write(f"\tif( (addr_i>>2) == ({row['addr']}>>2) )\n")
            fswreg_gen.write(f"\t\trready_int = ready_int | {reg}_ready_i;\n")
        else:
            #get wready
            fswreg_gen.write(f"\tif( (addr_i>>2) == ({row['addr']}>>2) )\n")
            fswreg_gen.write(f"\t\twready_int = ready_int | {reg}_ready_i;\n")

    fswreg_gen.write("end\n\n")

    #convert computed variables to signals
    fswreg_gen.write("assign ready_int = wstrb_i? wready_int: rready_int;\n")
    fswreg_gen.write("`IOB_VAR2WIRE(ready_int, ready_o)\n")
    fswreg_gen.write("`IOB_VAR2WIRE(rdata_int, rdata_o)\n")
    fswreg_gen.write("`IOB_VAR2WIRE(rvalid_int, rvalid_o)\n\n")

    fswreg_gen.write("endmodule\n")
    fswreg_gen.close()
    fswreg_inst.close()


def write_hwheader(table, top):
    fswreg_def = open(f"{top}_swreg_def.vh", "w")
    fswreg_def.write("//This file was generated by script mkregs.py\n\n")
    fswreg_def.write("//used address space width\n")
    addr_w_prefix = f"{top}_swreg".upper()
    fswreg_def.write(f"`define {addr_w_prefix}_ADDR_W {core_addr_w}\n\n")
    fswreg_def.write("//address macros\n")
    macro_prefix = f"{top}_".upper()
    fswreg_def.write("//addresses\n")
    for row in table:
        reg = row['name']
        reg_w = row['nbits']
        fswreg_def.write(f"`define {macro_prefix}{reg}_ADDR {row['addr']}\n")
        fswreg_def.write(f"`define {macro_prefix}{reg}_W {reg_w}\n\n")
    fswreg_def.close()

# Read vh files to get non-literal widths
def get_defines(vh_files):
    # .vh file lines
    vh = []
    for vh_file in vh_files:
        if vh_file.find(".vh"):
            fvh = open(vh_file, "r")
            vh = [*vh, *fvh.readlines()]
            fvh = close()
    defines = {}
    # parse headers if any
    if vh:
        header_parse(vh, defines)
    return defines

# Get C type from swreg nbytes
# uses unsigned int types from C stdint library
def swreg_type(reg, nbytes):
    type_dict = {1: "uint8_t", 2: "uint16_t", 4: "uint32_t", 8: "uint64_t"}
    try:
        type_try = type_dict[nbytes]
    except:
        print(f"Error: register {reg} has invalid number of bytes {nbytes}.")
    return type_try


def write_swheader(table, top, defines):
    fswhdr = open(f"{top}_swreg.h", "w")

    core_prefix = f"{top}_".upper()

    fswhdr.write("//This file was generated by script mkregs.py\n\n")
    fswhdr.write(f"#ifndef H_{core_prefix}SWREG_H\n")
    fswhdr.write(f"#define H_{core_prefix}SWREG_H\n\n")
    fswhdr.write("#include <stdint.h>\n\n")

    fswhdr.write("//register/memory address mapping\n")

    fswhdr.write("//Write Addresses\n")
    for row in table:
        reg = row['name']
        if row["rw_type"] == "W":
            fswhdr.write(f"#define {core_prefix}{reg} {row['addr']}\n")

    fswhdr.write("//Read Addresses\n")
    for row in table:
        reg = row['name']
        if row["rw_type"] == "R":
            fswhdr.write(f"#define {core_prefix}{reg} {row['addr']}\n")

    fswhdr.write("\n//register/memory data widths (bit)\n")

    fswhdr.write("//Write Register/Memory\n")
    for row in table:
        reg = row['name']
        if row["rw_type"] == "W":
            fswhdr.write(f"#define {core_prefix}{reg}_W {row['nbytes']*8}\n")

    fswhdr.write("//Read Register/Memory\n")
    for row in table:
        reg = row['name']
        if row["rw_type"] == "R":
            fswhdr.write(f"#define {core_prefix}{reg}_W {row['nbytes']*8}\n")

    fswhdr.write("\n// Base Address\n")
    fswhdr.write(f"void {core_prefix}INIT_BASEADDR(uint32_t addr);\n")

    fswhdr.write("\n// Core Setters\n")
    for row in table:
        reg = row['name']
        if row["rw_type"] == "W":
            sw_type = swreg_type(reg, row['nbytes'])
            fswhdr.write(f"void {core_prefix}SET_{reg}({sw_type} value);\n")

    fswhdr.write("\n// Core Getters\n")
    for row in table:
        reg = row['name']
        if row["rw_type"] == "R":
            sw_type = swreg_type(reg, row['nbytes'])
            fswhdr.write(f"{sw_type} {core_prefix}GET_{reg}();\n")

    fswhdr.write(f"\n#endif // H_{core_prefix}_SWREG_H\n")

    fswhdr.close()


def write_sw_emb(table, top, defines):
    fsw = open(f"{top}_swreg_emb.c", "w")
    core_prefix = f"{top}_".upper()
    fsw.write("//This file was generated by script mkregs.py\n\n")
    fsw.write(f'#include "{top}_swreg.h"\n\n')
    fsw.write("\n// Base Address\n")
    fsw.write("static int base;\n")
    fsw.write(f"void {core_prefix}INIT_BASEADDR(uint32_t addr) {{\n")
    fsw.write("\tbase = addr;\n")
    fsw.write("}\n")
    fsw.write("\n// Core Setters\n")
    for row in table:
        reg = row['name']
        if row["rw_type"] == "W":
            sw_type = swreg_type(reg, row['nbytes'])
            fsw.write(f"void {core_prefix}SET_{reg}({sw_type} value) {{\n")
            fsw.write(f"\t(*( (volatile {sw_type} *) ( (base) + ({core_prefix}{reg}) ) ) = (value));\n")
            fsw.write("}\n\n")
    fsw.write("\n// Core Getters\n")
    for row in table:
        reg = row['name']
        if row["rw_type"] == "R":
            sw_type = swreg_type(reg, row['nbytes'])
            fsw.write(f"{sw_type} {core_prefix}GET_{reg}() {{\n")
            fsw.write(f"\treturn (*( (volatile {sw_type} *) ( (base) + ({core_prefix}{reg}) ) ));\n")
            fsw.write("}\n\n")
    fsw.close()

# Calculate address
def calc_swreg_addr(table):
    read_addr = 0
    write_addr = 0

    for row in table:
        reg = row['name']
        reg_addr = row['addr']
        reg_addr_w = row['addr_w']
        reg_w = row['nbits']
        reg_nbytes = row['nbytes']
        reg_offset = 2**row['addr_w']
        if reg_addr >= 0:
            #manual adress
            if reg_addr%reg_nbytes != 0:
                sys.exit(f"Error: adress {reg_addr} for {reg_nbytes}-byte data {reg} is not aligned")
            if row['rw_type'] == "R" and reg_addr >= read_addr:
                read_addr = reg_addr+reg_offset
            elif row['rw_type'] == "W" and reg_addr >= write_addr:
                write_addr = reg_addr+reg_offset
            else:
                sys.exit(f"Error: Overlapped address {reg} {row['rw_type']} addr={reg_addr} addr_w={reg_addr_w} wa={write_addr} ra={read_addr} ro={reg_offset}")
        else:
            #auto address
            if row['rw_type'] == "R" and reg_addr >= read_addr:
                read_addr = read_addr+reg_nbytes-read_addr%reg_w
                row['addr'] = read_addr
                read_addr = read_addr + reg_offset
            elif row['rw_type'] == "W" and reg_addr >= write_addr:
                write_addr = write_addr+reg_nbytes-write_addr%reg_w
                row['addr'] = write_addr
                write_addr = write_addr + reg_offset
    max_addr = max(read_addr, write_addr)
    global core_addr_w
    core_addr_w = max(int(math.ceil(math.log(max_addr, 2))), 1)
    return table

def swreg_get_fields(line):
    # Parse IOB_SWREG_{R|W}(NAME, NBITS, RST_VAL, ADDR, ADDR_W) // Comment
    result = search("IOB_SWREG_{rw_type}({name},{nbits},{rst_val},{addr},{addr_w},{autologic}){wspace}//{description}\n", line)
    # Get dictionary of named fields from parse.Result object
    if result:
        swreg_flds = result.named
        # Remove whitespace
        for key in swreg_flds:
            swreg_flds[key] = swreg_flds[key].strip(" ").strip("\t")
    else:
        swreg_flds = None

    row = {'rw_type': '', 'name': '', 'nbits': 0, 'nbytes': 0, 'rst_val': 0, 'addr': 0, 'addr_w': 0, 'autologic': True}

    if swreg_flds is None:
        row = None
    else:
        row['rw_type'] =  swreg_flds['rw_type']
        row['name'] =  swreg_flds['name']
        row['nbits'] =  int(swreg_flds['nbits'])
        row['nbytes'] = int(int(swreg_flds['nbits'])/8) + (int(swreg_flds['nbits'])%8 > 0)
        row['rst_val'] =  int(swreg_flds['rst_val'])
        row['addr'] =  int(swreg_flds['addr'])
        row['addr_w'] =  int(swreg_flds['addr_w'])
        row['autologic'] =  bool(int(swreg_flds['autologic']))
        row['wspace'] =  swreg_flds['wspace']
        row['description'] =  swreg_flds['description']
    
    return row


def swreg_parse(code, hwsw, top, vh_files):
    # build table: list of swreg dictionaries
    table = []
    for line in code:
        row = swreg_get_fields(line)
        if row is None:
            continue
        table.append(row)
    # calculate address field
    table = calc_swreg_addr(table)
    if hwsw == "HW":
        write_hwheader(table, top)
        write_hwcode(table, top)
    elif hwsw == "SW":
        core_prefix = top.upper()
        defines = get_defines(vh_files)
        write_swheader(table, top, defines)
        write_sw_emb(table, top, defines)

def main():
    quit
    # parse command line
    args = parse_arguments()
    # parse input file
    config_file_name = f"{args.PATH}/mkregs.conf"
    try:
        fin = open(config_file_name, "r")
    except FileNotFoundError:
        print(f"Could not open {config_file_name}")
        quit()
    defsfile = fin.readlines()
    fin.close()
    swreg_parse(defsfile, args.hwsw, args.TOP, args.vh_files)

if __name__ == "__main__":
    main()
