#!/usr/bin/env python3
#
#    mkregs.py: build Verilog software accessible registers and software getters and setters
#

import sys
from math import ceil, log

cpu_nbytes = 4
core_addr_w = None


def parse_arguments():
    help_str = """
    mkregs.toml file:
        The configuration file supports the following toml format:
            [[latex_table_name]]
            REG1_NAME = {rw_type="W", nbits=1, rst_val=0, addr=-1, n=1, autologic=true, description="Description comment."}
            REG2_NAME = {rw_type="R", nbits=1, rst_val=0, addr=-1, n=1, autologic=true, description="Description comment."}
    """

    parser = argparse.ArgumentParser(
            description="mkregs.py script generates hardware logic and bare-metal software drivers to interface core with CPU.",
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog=help_str
            )

    parser.add_argument("TOP", help="""Top/core module name""")
    parser.add_argument("PATH", help="""Path to mkregs.toml file""")
    parser.add_argument("hwsw", choices=['HW', 'SW'],
                        help="""HW: generate the hardware files
                        SW: generate the software files"""
                        )
    parser.add_argument("--out_dir",
                        default=".",
                        help="""Output file directory""")
    parser.add_argument("vh_files",
                        nargs='*',
                        help="""paths to .vh files used to import HW macros to SW macros"""
                        )

    return parser.parse_args()

def bfloor(word, base):
    return base*int(word/base)

def bceil(word, base):
    return base*ceil(word/base)

def gen_wr_reg(row, f):
    name = row['name']
    rst_val = row['rst_val']
    nbits = row['nbits']
    nbytes = bceil(nbits,8)
    addr = row['addr']
    addr_w = row['addr_w']
    byte_offset = addr % cpu_nbytes

    #extract address byte offset
    f.write(f"\n`IOB_WIRE({name}_byte_offset, $clog2({cpu_nbytes}))\n")
    f.write(f"\niob_wstrb2byte_offset #({cpu_nbytes}) {name}_bo_inst (iob_wstrb_i, {name}_byte_offset);\n")

    #compute address
    f.write(f"\n`IOB_WIRE({name}_addr, ADDR_W)\n")
    f.write(f"assign {name}_addr = `IOB_WORD_ADDR(iob_addr_i) + {name}_byte_offset;\n")

    #compute wdata with only the needed bits
    f.write(f"`IOB_WIRE({name}_wdata, {nbits})\n")
    f.write(f"assign {name}_wdata = iob_wdata_i[{8*byte_offset}+:{nbits}];\n")

    #check if address in range
    f.write(f"`IOB_WIRE({name}_addressed, )\n")
    f.write(f"assign {name}_addressed = ({name}_addr >= {addr} && {name}_addr < {addr+2**addr_w});\n")

    #declare wen signal
    f.write(f"`IOB_WIRE({name}_wen, 1)\n")

    #generate register logic
    if row['autologic']: #generate register and ready signal
        f.write(f"`IOB_WIRE({name}_ready_i, 1)\n")
        f.write(f"assign {name}_ready_i = |iob_wstrb_i;\n")
        f.write(f"iob_reg #({nbits},{rst_val}) {name}_datareg (clk_i, rst_i, 1'b0, {name}_wen, {name}_wdata, {name}_o);\n")
    else: #output wdata and wen; ready signal has been declared as a port
        f.write(f"assign {name}_o = {name}_wdata;\n")
        f.write(f"assign {name}_wen_o = {name}_wen;\n")

    #compute write enable
    f.write(f"assign {name}_wen = {name}_ready_i && iob_valid_i && iob_wstrb_i && {name}_addressed;\n")

    #compute address for register range
    if addr_w > 0:
        f.write(f"assign {name}_addr_o = iob_addr_i[{addr_w}-1:0];\n")

def gen_rd_reg(row, f):
    name = row['name']
    rst_val = row['rst_val']
    nbits = row['nbits']
    nbytes = nbytes(nbits)
    addr = row['addr']
    addr_w = row['addr_w']
    byte_offset = row['addr'] % cpu_nbytes

    #declare ren signal
    f.write(f"\n`IOB_WIRE({name}_ren, 1)\n")

    #generate register logic
    if row['autologic']:#generate register, ready, rvalid signal
        #ready
        f.write(f"`IOB_WIRE({name}_ready_i, 1)\n")
        f.write(f"assign {name}_ready_i = !iob_wstrb_i;\n")
        #rvalid
        f.write(f"`IOB_WIRE({name}_rvalid_i, 1)\n")
        f.write(f"iob_reg #(1,0) {name}_rvalid (clk_i, rst_i, 1'b0, 1'b1, {name}_ren, {name}_rvalid_i);\n")
        #register
        f.write(f"`IOB_WIRE({name}_r, {nbits})\n")
        f.write(f"iob_reg #({nbits},{rst_val}) {name}_datareg (clk_i, rst_i, 1'b0, {name}_ren, {name}_i, {name}_r);\n")
        f.write(f"assign {name}_int_o = {name}_r;\n")
    else:
        f.write(f"assign {name}_ren_o = {name}_ren;\n")

    #check if address in range
    f.write(f"`IOB_WIRE({name}_addressed, )\n")
    f.write(f"assign {name}_addressed = `IOB_WORD_ADDR(iob_addr_i) >= {floor_word_addr(addr)} && `IOB_WORD_ADDR(iob_addr_i) <= {ceil_word_addr(addr, 2**addr_w)};\n")
    f.write(f"assign {name}_addressed = (iob_addr_i >= {addr} && iob_addr_i < {addr+2**addr_w});\n")

    #compute the read enable signal
    f.write(f"assign {name}_ren = {name}_ready_i && iob_valid_i && !iob_wstrb_i && {name}_addressed")
    if addr_w > log(cpu_nbytes,2):
        f.write(f"assign {name}_addr_o = iob_addr_i[{addr_w}-1:0];\n")


def gen_port(table, f):
    for row in table:
        name = row['name']
        nbits = row['nbits']
        addr_w = row['addr_w']
        if row['rw_type'] == 'W':
            f.write(f"\t`IOB_OUTPUT({name}_o, {nbits}),\n")
            if not row['autologic']:
                f.write(f"\t`IOB_OUTPUT({name}_wen_o, 1),\n")
        else:
            f.write(f"\t`IOB_INPUT({name}_i, {nbits}),\n")
            if not row['autologic']:
                f.write(f"\t`IOB_OUTPUT({name}_ren_o, 1),\n")
                f.write(f"\t`IOB_INPUT({name}_rvalid_i, 1),\n")
            else:
                f.write(f"\t`IOB_OUTPUT({name}_int_o, {nbits}),\n")
        if not row['autologic']:
            f.write(f"\t`IOB_INPUT({name}_ready_i, 1),\n")
        if addr_w > log(cpu_nbytes,2):
            f.write(f"\t`IOB_OUTPUT({name}_addr_o, {addr_w}),\n")


def gen_inst_wire(table, f):
    for row in table:
        name = row['name']
        nbits = row['nbits']
        addr_w = row['addr_w']
        if row['rw_type'] == 'W':
            f.write(f"`IOB_WIRE({name}, {nbits})\n")
            if not row['autologic']:
                f.write(f"`IOB_WIRE({name}_wen, 1)\n")
        else:
            f.write(f"`IOB_WIRE({name}, {nbits})\n")
            if not row['autologic']:
                f.write(f"`IOB_WIRE({name}_rvalid, 1)\n")
                f.write(f"`IOB_WIRE({name}_ren, 1)\n")
            else:
                f.write(f"`IOB_WIRE({name}_int, {nbits})\n")
        if not row['autologic']:
            f.write(f"`IOB_WIRE({name}_ready, 1)\n")
        if row['addr_w'] > cpu_nbytes:
            f.write(f"`IOB_WIRE({name}_addr, {addr_w})\n")
    f.write("\n")


def gen_portmap(table, f):
    for row in table:
        name = row['name']
        if row['rw_type'] == 'W':
            f.write(f"\t.{name}_o({name}),\n")
            if not row['autologic']:
                f.write(f"\t.{name}_wen_o({name}_wen),\n")
        else:
            f.write(f"\t.{name}_i({name}),\n")
            if not row['autologic']:
                f.write(f"\t.{name}_rvalid_i({name}_rvalid),\n")
                f.write(f"\t.{name}_ren_o({name}_ren),\n")
            else:
                f.write(f"\t.{name}_int_o({name}_int),\n")
        if not row['autologic']:
            f.write(f"\t.{name}_ready_i({name}_ready),\n")
        if row['addr_w'] > log(cpu_nbytes,2):
            f.write(f"\t.{name}_addr_o({name}_addr),\n")


def write_hwcode(table, out_dir, top):

    #
    # SWREG INSTANCE
    #

    f_inst = open(f"{out_dir}/{top}_swreg_inst.vh", "w")
    f_inst.write("//This file was generated by script mkregs.py\n\n")

    # connection wires
    gen_inst_wire(table, f_inst)

    f_inst.write("swreg #(ADDR_W, DATA_W) swreg_inst (\n")
    gen_portmap(table, f_inst)
    f_inst.write('\t`include "iob_s_portmap.vh"\n')
    f_inst.write('\t`include "iob_clkrst_portmap.vh"')
    f_inst.write("\n);\n")

    #
    # SWREG MODULE
    #

    f_gen = open(f"{out_dir}/{top}_swreg_gen.v", "w")
    f_gen.write("//This file was generated by script mkregs.py\n\n")

    # time scale
    f_gen.write("`timescale 1ns / 1ps\n\n")

    # declaration
    f_gen.write("module swreg\n")

    # parameters
    f_gen.write("#(\n")
    f_gen.write("\tparameter ADDR_W = 0,\n")
    f_gen.write("\tparameter DATA_W = 0\n")
    f_gen.write(")\n")
    f_gen.write("(\n")

    # ports
    gen_port(table, f_gen)
    f_gen.write('\t`include "iob_s_port.vh"\n')
    f_gen.write('\t`include "iob_clkrst_port.vh"\n')
    f_gen.write(");\n\n")

    # register logic
    has_addr_r = 0
    for row in table:
        if row['type'] == 'W':
            # write register
            gen_wr_reg(row, f_gen)
        else:
            # read register
            gen_rd_reg(row, f_gen)
            # address register
            if not has_addr_r:
                has_addr_r = 1
                f_gen.write("//address register\n")
                f_gen.write(f"`IOB_WIRE(addr_r, {core_addr_w})\n")
                f_gen.write(f"iob_reg #({core_addr_w}, 0) addr_r0 (clk_i, rst_i, 1'b0, iob_valid_i, iob_addr_i, addr_r);\n\n")

    #
    # COMBINATORIAL RESPONSE SWITCH
    #

    # use variables to compute response
    f_gen.write(f"\n`IOB_VAR(rdata_int, 8*`IOB_NBYTES)\n")
    f_gen.write("`IOB_VAR(rvalid_int, 1)\n")
    f_gen.write("`IOB_VAR(wready_int, 1)\n")
    f_gen.write("`IOB_VAR(rready_int, 1)\n")
    f_gen.write("`IOB_WIRE(ready_int, 1)\n\n")

    f_gen.write("`IOB_COMB begin\n\n")

    # response defaults
    f_gen.write("\twready_int = 1'b0;\n")
    f_gen.write("\trready_int = 1'b0;\n")
    f_gen.write("\trdata_int = 0;\n")
    f_gen.write("\trvalid_int = 1'b0;\n\n")

    # update responses
    for row in table:
        name = row['name']
        addr = row['addr']
        # compute rdata and rvalid
        if row['type'] == 'R':
            # get rdata and rvalid
            f_gen.write(f"\tif( `IOB_WORD_ADDR(addr_r) >= {bfloor(addr, addr_w)} && `IOB_WORD_ADDR(addr_r) < {bfloor(addr+2**addr_w)})\n")
            # get rdata
            if row['autologic']:
                f_gen.write(f"\t\trdata_int = rdata_int | ({name}_r << (8*`IOB_BYTE_OFFSET({addr})));\n")
            else:
                f_gen.write(f"\t\trdata_int = rdata_int | ({name}_i << (8*`IOB_BYTE_OFFSET({addr})));\n")
            # get rvalid
            f_gen.write(f"\t\trvalid_int = rvalid_int | {name}_rvalid_i;\n")
            # get rready
            f_gen.write(f"\tif( `IOB_WORD_ADDR(iob_addr_i) >= {floor_word_addr(addr)} && `IOB_WORD_ADDR(iob_addr_i) <= {word_addr(addr + 2**row['addr_w'])})\n")
            f_gen.write(f"\t\trready_int = rready_int | {name}_ready_i;\n")
        else: #row['rw_type'] == 'W'
            # get wready
            f_gen.write(f"\tif( `IOB_WORD_ADDR(iob_addr_i) >= {word_addr(addr)} && `IOB_WORD_ADDR(iob_addr_i) <= {word_addr(addr + 2**row['addr_w'])})\n")
            f_gen.write(f"\t\twready_int = wready_int | {name}_ready_i;\n")

    f_gen.write("end\n\n")

    # convert computed variables to signals
    f_gen.write("assign ready_int = iob_wstrb_i? wready_int: rready_int;\n")
    f_gen.write("`IOB_VAR2WIRE(ready_int, iob_ready_o)\n")
    f_gen.write("`IOB_VAR2WIRE(rdata_int, iob_rdata_o)\n")
    f_gen.write("`IOB_VAR2WIRE(rvalid_int, iob_rvalid_o)\n\n")

    f_gen.write("endmodule\n")
    f_gen.close()
    f_inst.close()


def write_hwheader(table, out_dir, top):
    f_def = open(f"{out_dir}/{top}_swreg_def.vh", "w")
    f_def.write("//This file was generated by script mkregs.py\n\n")
    f_def.write("//used address space width\n")
    addr_w_prefix = f"{top}_swreg".upper()
    f_def.write(f"`define {addr_w_prefix}_ADDR_W {core_addr_w}\n\n")
    f_def.write("//address macros\n")
    macro_prefix = f"{top}_".upper()
    f_def.write("//addresses\n")
    for row in table:
        name = row['name']
        nbits = row['nbits']
        f_def.write(f"`define {macro_prefix}{name}_ADDR {row['addr']}\n")
        f_def.write(f"`define {macro_prefix}{name}_W {nbits}\n\n")
    f_def.close()


# Get C type from swreg nbytes
# uses unsigned int types from C stdint library
def swreg_type(reg, nbytes):
    type_dict = {1: "uint8_t", 2: "uint16_t", 4: "uint32_t", 8: "uint64_t"}
    try:
        type_try = type_dict[nbytes]
    except KeyError:
        print(f"Error: register {name} has invalid number of bytes {nbytes}.")
    return type_try


def write_swheader(table, out_dir, top):
    fswhdr = open(f"{out_dir}/{top}_swreg.h", "w")

    core_prefix = f"{top}_".upper()

    fswhdr.write("//This file was generated by script mkregs.py\n\n")
    fswhdr.write(f"#ifndef H_{core_prefix}SWREG_H\n")
    fswhdr.write(f"#define H_{core_prefix}SWREG_H\n\n")
    fswhdr.write("#include <stdint.h>\n\n")

    fswhdr.write("//Addresses\n")
    for row in table:
        name = row['name']
        if row["rw_type"] == "W":
            fswhdr.write(f"#define {core_prefix}{name} {row['addr']}\n")
        if row["rw_type"] == "R":
            fswhdr.write(f"#define {core_prefix}{name} {row['addr']}\n")

    fswhdr.write("\n//Data widths (bit)\n")
    for row in table:
        name = row['name']
        nbytes = bceil(row['nbits'], 8)
        if row["rw_type"] == "W":
            fswhdr.write(f"#define {core_prefix}{name}_W {nbytes*8}\n")
        if row["rw_type"] == "R":
            fswhdr.write(f"#define {core_prefix}{name}_W {nbytes*8}\n")

    fswhdr.write("\n// Base Address\n")
    fswhdr.write(f"void {core_prefix}INIT_BASEADDR(uint32_t addr);\n")

    fswhdr.write("\n// Core Setters and Getters\n")
    for row in table:
        name = row['name']
        nbytes = bceil(row['nbits'], 8)
        if row["rw_type"] == "W":
            sw_type = swreg_type(reg, nbytes)
            addr_arg = ""
            if row['addr_w'] / nbytes > 1:
                addr_arg = ", int addr"
            fswhdr.write(f"void {core_prefix}SET_{name}({sw_type} value{addr_arg});\n")
        if row["rw_type"] == "R":
            sw_type = swreg_type(reg, nbytes  )
            addr_arg = ""
            if row['addr_w'] / nbytes > 1:
                addr_arg = "int addr"
            fswhdr.write(f"{sw_type} {core_prefix}GET_{name}({addr_arg});\n")

    fswhdr.write(f"\n#endif // H_{core_prefix}_SWREG_H\n")

    fswhdr.close()


def write_swcode(table, out_dir, top):
    fsw = open(f"{out_dir}/{top}_swreg_emb.c", "w")
    core_prefix = f"{top}_".upper()
    fsw.write("//This file was generated by script mkregs.py\n\n")
    fsw.write(f'#include "{top}_swreg.h"\n\n')
    fsw.write("\n// Base Address\n")
    fsw.write("static int base;\n")
    fsw.write(f"void {core_prefix}INIT_BASEADDR(uint32_t addr) {{\n")
    fsw.write("\tbase = addr;\n")
    fsw.write("}\n")

    fsw.write("\n// Core Setters and Getters\n")

    for row in table:
        name = row['name']
        nbytes = bceil(row['nbits'],8)
        if row["rw_type"] == "W":
            sw_type = swreg_type(reg, nbytes)
            addr_arg = ""
            addr_arg = ""
            addr_shift = ""
            if row['addr_w'] / nbytes > 1:
                addr_arg = ", int addr"
                addr_shift = f" + (addr << {int(log(nbytes, 2))})"
            fsw.write(f"void {core_prefix}SET_{name}({sw_type} value{addr_arg}) {{\n")
            fsw.write(f"\t(*( (volatile {sw_type} *) ( (base) + ({core_prefix}{name}){addr_shift}) ) = (value));\n")
            fsw.write("}\n\n")
        if row["rw_type"] == "R":
            sw_type = swreg_type(reg, nbytes)
            addr_arg = ""
            addr_shift = ""
            if row['addr_w'] / nbytes > 1:
                addr_arg = "int addr"
                addr_shift = f" + (addr << {int(log(nbytes, 2))})"
            fsw.write(f"{sw_type} {core_prefix}GET_{name}({addr_arg}) {{\n")
            fsw.write(f"\treturn (*( (volatile {sw_type} *) ( (base) + ({core_prefix}{name}){addr_shift}) ));\n")
            fsw.write("}\n\n")
    fsw.close()

def check_alignment(addr, addr_w):
    if addr % (2**addr_w) != 0:
        sys.exit(f"Error: address {addr} with span {2**addr_w} is not aligned")

def check_overlap(addr, last_addr):
    if(addr < last_addr):
        sys.exit(f"Error: address {addr} overlap with previous addresses")

def compute_addr_next(addr, addr_w, addr_type, read_addr, write_addr, no_overlap):
    addr_span = 2**addr_w
    if addr_type == "R":
        read_addr = addr + addr_span
    elif addr_type == "W" and write_addr <= addr:
        write_addr = addr + addr_span

    if no_overlap:
        addr_next = max(read_addr, write_addr)
        read_addr = addr_next
        write_addr = addr_next

    return read_addr, write_addr

            
# compute address
def compute_addr(table, no_overlap):
    read_addr = 0
    write_addr = 0

    # Assign manual addresses
    for row in table:
        addr = row['addr']
        addr_type = row['rw_type']
        addr_w = row['addr_w']
        if addr >= 0: #manual address
            check_alignment(addr, addr_w)
            check_overlap(addr, addr_type, read_addr, write_addr)
        elif addr_type == 'R': #auto address
            read_addr = bceil(read_addr, 2**addr_w)
            row['addr'] = read_addr
        elif row['rw_type'] == "W":
            write_addr = bceil(write_addr, 2**addr_w)
            row['addr'] = write_addr
    
        read_addr, write_addr = compute_addr_next(addr, addr_w, addr_type, read_addr, write_addr, no_overlap)

    #update core address space size
    global core_addr_w
    core_addr_w = int(ceil(log(max(read_addr, write_addr), 2)))

# return table: list of swreg dictionaries based on toml configuration
def swreg_list(regs):
    for i in range(len(regs)):
        regs[i]['nbytes'] = ceil(regs[i]['nbits']/8.0)

    # calculate address field
    table = compute_addr(table, True)

    return table

# process swreg configuration
def swreg_proc(toml_dict, hwsw, top, out_dir):
#    table = swreg_list(toml_dict)
    table = toml_dict
    if hwsw == "HW":
        write_hwheader(table, out_dir, top)
        write_hwcode(table, out_dir, top)
    elif hwsw == "SW":
        write_swheader(table, out_dir, top)
        write_swcode(table, out_dir, top)

#
# Main
#

def mkregs(regs, hwsw, top, out_dir):
    swreg_proc(regs, hwsw, top, out_dir)
