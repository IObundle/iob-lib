#!/usr/bin/env python3
#
#    mkregs.py: build Verilog software accessible registers and software getters and setters
#

import sys
import argparse
from parse import parse, search
import math

cpu_nbytes = 4

def parse_arguments():
    help_str = """
    mkregs.conf file:
        The configuration file supports the following register/memory
        declarations:
            IOB_SWREG_R(NAME, NBYTES, RST_VAL, ADDR, ADDR_W) // Description
                sw can read:
                    NAME[0-(2^ADDR_W-1)]
                hw can read:
                    wire NAME_addr;
                    wire NAME_ren;
                    wire NAME_wen;
                hw can write:
                    wire NAME_rdata;
                    wire NAME_rvalid;
                    wire NAME_ready;
            IOB_SWREG_W(NAME, NBYTES, RST_VAL, ADDR, ADDR_W) // Description
                sw can write:
                    NAME[0-(2^ADDR_W-1)]
                hw can read:
                    wire NAME_wdata;
                    wire NAME_wen;
                    wire NAME_addr;
                    wire NAME_wstrb;
                hw can write:
                    wire NAME_ready;
    """

    parser = argparse.ArgumentParser(
            description="mkregs.py script generates hardware logic and software drivers to interface core with CPU.",
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

    byte_offset = int(row['addr']) % 4
    reg_addr = math.floor(int(row['addr'])/cpu_nbytes)
    reg_w = int(row['nbytes']) * 8
    f.write(f"`IOB_WIRE({row['name']}_wen, 1)\n")
    f.write(f"assign {row['name']}_wen = valid & (|wstrb[{byte_offset}+:{row['nbytes']}]) & (addr == {reg_addr});\n")
    f.write(f"`IOB_WIRE({row['name']}_wdata, {reg_w})\n")
    f.write(f"assign {row['name']}_wdata = wdata[{8*byte_offset}+:{reg_w}];\n")
    f.write(f"`IOB_WIRE({row['name']}_ready, 1)\n\n")

    if row['autologic']:
        f.write(f"assign {row['name']}_ready == 1'b1)\n")
        f.write(f"iob_reg {row['name']}_datareg (clk_i, rst_i, 1'b0, {row['name']}_wen, {row['name']}_wdata, {row['name']})")

def gen_rd_reg(row, f):

    f.write(f"`IOB_WIRE({row['name']}_ren, 1)\n")
    f.write(f"`IOB_WIRE({row['name']}_rdata, {int(row['nbytes']) * 8})\n")
    f.write(f"`IOB_WIRE({row['name']}_rvalid, 1)\n")
    f.write(f"`IOB_WIRE({row['name']}_ready, 1)\n")
    cpu_reg_addr = math.floor(int(row['addr'])/cpu_nbytes)
    f.write(f"assign {row['name']}_ren = valid & ( addr == {cpu_reg_addr} ) & ~(|wstrb);\n")
    f.write("default: rd_reg_rdata_int = 1'b0;\n")
    f.write("endcase\n")
    f.write("end\n")

    #ready logic
    if row['autologic']:
            f.write("assign {row['name']}_ready = !wstrb;\n")


    
def gen_port(table, f):
    for row in table:
        if row['rw_type'] == 'W':
            f.write(f"`IOB_OUTPUT({row['name']}_o, {str(8*int(row['nbytes']))}),\n")
        else:
            f.write(f"`IOB_INPUT({row['name']}_i, {str(8*int(row['nbytes']))}),\n")
            if row['autologic']:
                f.write(f"`IOB_OUTPUT({row['name']}_rvalid);\n")
        if row['autologic']:
            f.write(f"`IOB_OUTPUT({row['name']}_ready);\n")
            
        
def gen_wire(table, f):
    for row in table:
        if row['rw_type'] == 'W':
            f.write(f"`IOB_WIRE({row['name']}_o, {str(8*int(row['nbytes']))}),\n")
        else:
            f.write(f"`IOB_WIRE({row['name']}_i, {str(8*int(row['nbytes']))}),\n")
            if row['autologic']:
                f.write(f"`IOB_WIRE({row['name']}_rvalid);\n")
        if row['autologic']:
            f.write(f"`IOB_WIRE({row['name']}_ready);\n")
            
        
def gen_portmap(table, f):
    for row in table:
        if row['rw_type'] == 'W':
            f.write(f".{row['name']}_o({row['name']})\n")
        else:
            f.write(f".{row['name']}_i({row['name']})\n")
            if row['autologic']:
                f.write(f"`IOB_OUTPUT({row['name']}_rvalid);\n")
        if row['autologic']:
            f.write(f"`IOB_OUTPUT({row['name']}_ready);\n")
            
        
def write_hwcode(table, top):

    #top-level instance
    fswreg_inst = open(f"{top}_swreg_inst.vh", "w")
    gen_wire(table, fswreg_inst)

    fswreg_inst.write("swreg swreg_inst (\n")
    gen_portmap(table, fswreg_inst)
    fswreg_inst.write('\t`include "iob_s_portmap.vh"')
    fswreg_inst.write('\t`include "iob_clkrst_s_portmap.vh"')
    fswreg_inst.write(")\n")

    #swreg module
    fswreg_gen = open(f"{top}_swreg_gen.v", "w")
    fswreg_gen.write("module swreg (\n")
    gen_port(table, fswreg_gen)
    fswreg_gen.write('`include "iob_s_port.vh"')
    fswreg_gen.write('`include "iob_clkrst_s_port.vh"')    
    fswreg_gen.write(");\n")

    has_addr_reg = 0
    for row in table:
        if row['rw_type'] == 'W':
            #write register 
            gen_wr_reg(row, fswreg_gen)
        else:
            #read register 
            gen_rd_reg(row, fswreg_gen)
            #address register
            if not has_addr_reg:
                has_addr_reg = 1
                fswreg_gen.write("//address register\n")
                fswreg_gen.write("`IOB_WIRE(addr_reg, ADDR_W)\n")
                fswreg_gen.write("iob_reg #(ADDR_W, 0) addr_reg0 (clk_i, rst_i, 1'b0, valid, addr, addr_reg);\n\n")


    #select response
    fswreg_gen.write(f"`IOB_VAR(rdata_int, {str(8*cpu_nbytes)})\n")
    fswreg_gen.write("`IOB_VAR(rvalid_int, 1)\n")
    fswreg_gen.write("`IOB_VAR(ready_int, 1)\n")

    fswreg_gen.write("`IOB_COMB begin\n")

    #defaults
    fswreg_gen.write("rdata_int = 0;\n")    
    fswreg_gen.write("rvalid_int = 1'b0;\n")
    fswreg_gen.write("ready_int = 1'b0;\n")

    for row in table:
        #compute ready 
        fswreg_gen.write(f"if( (addr>>2) == ({row['addr']}>>2) )\n")
        fswreg_gen.write(f"\tready_int = ready_int | {row['name']}_ready;\n")

        #compute rdata and rvalid
        if row['rw_type'] == 'R':
            fswreg_gen.write("rdata_int = 0;\n")
            fswreg_gen.write(f"if( (addr_reg>>2) == ({row['addr']}>>2) )"+"\}\n")
            fswreg_gen.write(f"rdata_int = rdata_int | ({row['name']}_rdata << (8*(int({row['addr']})%4));\n")
            fswreg_gen.write(f"rvalid_int = rvalid_int | {row['name']}_rvalid;\n"+"\}\n")
            fswreg_gen.write("end\n")

    fswreg_gen.write("`IOB_VAR2WIRE(ready_int, ready)\n")
    fswreg_gen.write("`IOB_VAR2WIRE(rdata_int, rdata)\n")
    fswreg_gen.write("`IOB_VAR2WIRE(rvalid_int, rvalid)\n")

    fswreg_gen.write("endmodule\n")
    fswreg_inst.write(");\n")
    fswreg_gen.close()
    fswreg_inst.close()


def write_hwheader(table, top, core_addr_w):

    fswreg_def = open(f"{top}_swreg_def.vh", "w")

    fswreg_def.write("//This file was generated by script mkregs.py\n\n")

    fswreg_def.write("//used address space width\n")
    addr_w_prefix = f"{top}_swreg".upper()
    fswreg_def.write(f"`define {addr_w_prefix}_ADDR_W {core_addr_w}\n\n")

    fswreg_def.write("//address macros\n")
    macro_prefix = f"{top}_".upper()

    fswreg_def.write("//addresses\n")
    for row in table:
        fswreg_def.write(f"`define {macro_prefix}{row['name']}_ADDR {row['addr']}\n")
        fswreg_def.write(f"`define {macro_prefix}{row['name']}_W {int(row['nbytes'])*8}\n\n")

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


# Get C type from swreg width
# uses unsigned int types from C stdint library
# nbytes: SWREG nbytes
def swreg_type(nbytes, defines):
    # Check if nbytes is a number string (1, 2, 4, etc)
    try:
        nbytes_int = int(nbytes)
    except ValueError:
        # width is a parameter or macro (example: DATA_W, ADDR_W)
        eval_str = nbytes.replace("`", "").replace(",", "")
        for key, val in defines.items():
            eval_str = eval_str.replace(str(key), str(val))
        try:
            nbytes_int = int(eval_str)
        except ValueError:
            # eval_str has undefined parameters: use default value
            nbytes_int = 4

    if nbytes_int < 1:
        print(f"MKREGS: invalid SWREG nbytes value {nbytes}.")
        nbytes_int = 4

    type_dict = {1: "uint8_t", 2: "uint16_t", 4: "uint32_t", 8: "uint64_t"}
    default_width = "uint64_t"

    return type_dict.get(nbytes_int, default_width)


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
        if row["rw_type"] == "W":
            fswhdr.write(f"#define {core_prefix}{row['name']} {row['addr']}\n")

    fswhdr.write("//Read Addresses\n")
    for row in table:
        if row["rw_type"] == "R":
            fswhdr.write(f"#define {core_prefix}{row['name']} {row['addr']}\n")

    fswhdr.write("\n//register/memory data widths (bit)\n")

    fswhdr.write("//Write Register/Memory\n")
    for row in table:
        if row["rw_type"] == "W":
            fswhdr.write(f"#define {core_prefix}{row['name']}_W {int(row['nbytes'])*8}\n")

    fswhdr.write("//Read Register/Memory\n")
    for row in table:
        if row["rw_type"] == "R":
            fswhdr.write(f"#define {core_prefix}{row['name']}_W {int(row['nbytes'])*8}\n")

    fswhdr.write("\n// Base Address\n")
    fswhdr.write(f"void {core_prefix}INIT_BASEADDR(uint32_t addr);\n")

    fswhdr.write("\n// Core Setters\n")
    for row in table:
        if row["rw_type"] == "W":
            sw_type = swreg_type(row['nbytes'], defines)
            fswhdr.write(f"void {core_prefix}SET_{row['name']}({sw_type} value);\n")

    fswhdr.write("\n// Core Getters\n")
    for row in table:
        if row["rw_type"] == "R":
            sw_type = swreg_type(row['nbytes'], defines)
            fswhdr.write(f"{sw_type} {core_prefix}GET_{row['name']}();\n")

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
        if row["rw_type"] == "W":
            sw_type = swreg_type(row['nbytes'], defines)
            fsw.write(f"void {core_prefix}SET_{row['name']}({sw_type} value) {{\n")
            fsw.write(f"\t(*( (volatile {sw_type} *) ( (base) + ({core_prefix}{row['name']}) ) ) = (value));\n")
            fsw.write("}\n\n")
    fsw.write("\n// Core Getters\n")
    for row in table:
        if row["rw_type"] == "R":
            sw_type = swreg_type(row['nbytes'], defines)
            fsw.write(f"{sw_type} {core_prefix}GET_{row['name']}() {{\n")
            fsw.write(f"\treturn (*( (volatile {sw_type} *) ( (base) + ({core_prefix}{row['name']}) ) ));\n")
            fsw.write("}\n\n")
    fsw.close()

# Calculate address
def calc_swreg_addr(table):
    read_addr = 0
    write_addr = 0
    for row in table:
        reg_nbytes = int(row['nbytes'])
        reg_offset = 2**int(row['addr_w'])
        if row['addr'].isdigit():
            #manual adress
            reg_addr = int(row['addr'])
            if row['rw_type'] == "R" and reg_addr >= read_addr:
                read_addr = reg_addr+reg_offset
            elif row['rw_type'] == "W" and reg_addr >= write_addr:
                write_addr = reg_addr+reg_offset
            else:
                sys.exit(f"Error: Overlapped address {row['name']} {row['rw_type']} addr={row['addr']} addr_w={row['addr_w']} wa={write_addr} ra={read_addr} ro={reg_offset}")
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
    core_addr_w = max(int(math.ceil(math.log(max_addr, 2))), 1)
    print (max_addr)
    return table, core_addr_w

def swreg_get_fields(line):
    # Parse IOB_SWREG_{R|W}(NAME, NBYTES, RST_VAL, ADDR, ADDR_W) // Comment
    result = search("IOB_SWREG_{rw_type}({name},{nbytes},{rst_val},{addr},{addr_w},{autologic}){wspace}//{description}\n", line)
    # Get dictionary of named fields from parse.Result object
    if result:
        swreg_flds = result.named
        # Remove whitespace
        for key in swreg_flds:
            swreg_flds[key] = swreg_flds[key].strip(" ").strip("\t")
    else:
        swreg_flds = None
    return swreg_flds


def swreg_parse(code, hwsw, top, vh_files):
    # build table: list of swreg dictionaries
    table = []
    for line in code:
        swreg_flds = swreg_get_fields(line)
        if swreg_flds is None:
            continue
        table.append(swreg_flds)
    # calculate address field
    table, core_addr_w = calc_swreg_addr(table)
    if hwsw == "HW":
        write_hwheader(table, top, core_addr_w)
        write_hwcode(table, top)
    elif hwsw == "SW":
        core_prefix = top.upper()
        defines = get_defines(vh_files)
        write_swheader(table, top, defines)
        write_sw_emb(table, top, defines)

def main():
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
