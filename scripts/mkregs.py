#!/usr/bin/env python3
#
#    mkregs.py: build Verilog software accessible registers and software getters and setters
#

import sys
import argparse
import tomli
from math import ceil, log

cpu_nbytes = 4
core_addr_w = None


def parse_arguments():
    help_str = """
    mkregs.toml file:
        The configuration file supports the following toml format:
            [[latex_table_name]]
            REG1_NAME = {rw_type="W", nbits=1, rst_val=0, addr=-1, addr_w=0, autologic=true, description="Description comment."}
            REG2_NAME = {rw_type="R", nbits=1, rst_val=0, addr=-1, addr_w=0, autologic=true, description="Description comment."}
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


def gen_wr_reg(row, f):
    reg = row['name']
    reg_w = row['nbits']
    byte_offset = row['addr'] % cpu_nbytes
    reg_addr = row['addr']
    reg_addr_w = row['addr_w']
    reg_rst_val = row['rst_val']
    f.write(f"\n`IOB_WIRE({reg}_wen, 1)\n")
    f.write(f"assign {reg}_wen = iob_valid_i & (|iob_wstrb_i[{byte_offset}+:{row['nbytes']}]) & `IOB_WORD_ADDR(iob_addr_i) >= `IOB_WORD_ADDR({reg_addr}) & `IOB_WORD_ADDR(iob_addr_i) < `IOB_WORD_CADDR({reg_addr} + (1'b1<<{reg_addr_w}));\n")
    f.write(f"`IOB_WIRE({reg}_wdata, {reg_w})\n")
    f.write(f"assign {reg}_wdata = iob_wdata_i[{8*byte_offset}+:{reg_w}];\n")
    if row['autologic']:
        f.write(f"`IOB_WIRE({reg}_ready_i, 1)\n")
        f.write(f"assign {reg}_ready_i = |iob_wstrb_i;\n")
        f.write(f"iob_reg #({reg_w},{reg_rst_val}) {reg}_datareg (clk_i, rst_i, 1'b0, {reg}_wen, {reg}_wdata, {reg}_o);\n")
    else:
        f.write(f"assign {reg}_o = {reg}_wdata;\n")
    if row['addr_w'] > cpu_nbytes:
        f.write(f"assign {reg}_addr_o = iob_addr_i[{reg_addr_w}-1:0];\n")


def gen_rd_reg(row, f):
    reg = row['name']
    reg_w = row['nbits']
    reg_addr = row['addr']
    reg_addr_w = row['addr_w']
    reg_rst_val = row['rst_val']
    f.write(f"\n`IOB_WIRE({reg}_ren, 1)\n")
    f.write(f"assign {reg}_ren = iob_valid_i && !iob_wstrb_i && `IOB_WORD_ADDR(iob_addr_i) >= `IOB_WORD_ADDR({reg_addr}) && `IOB_WORD_ADDR(iob_addr_i) < `IOB_WORD_CADDR({reg_addr} + (1'b1<<{reg_addr_w}));\n")
    if row['autologic']:
        f.write(f"`IOB_WIRE({reg}_ready_i, 1)\n")
        f.write(f"assign {reg}_ready_i = !iob_wstrb_i;\n")
        f.write(f"`IOB_WIRE({reg}_rvalid_i, 1)\n")
        f.write(f"iob_reg #(1,0) {reg}_rvalid (clk_i, rst_i, 1'b0, 1'b1, {reg}_ren, {reg}_rvalid_i);\n")
        f.write(f"`IOB_WIRE({reg}_r, {reg_w})\n")
        f.write(f"iob_reg #({reg_w},{reg_rst_val}) {reg}_datareg (clk_i, rst_i, 1'b0, {reg}_ren, {reg}_i, {reg}_r);\n")
        f.write(f"assign {reg}_int_o = {reg}_r;\n")
    else:
        f.write(f"assign {reg}_ren_o = {reg}_ren;\n")
    if row['addr_w'] > cpu_nbytes:
        f.write(f"assign {reg}_addr_o = iob_addr_i[{reg_addr_w}-1:0];\n")


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


def write_hwcode(table, out_dir, top):

    #
    # SWREG INSTANCE
    #

    fswreg_inst = open(f"{out_dir}/{top}_swreg_inst.vh", "w")
    fswreg_inst.write("//This file was generated by script mkregs.py\n\n")

    # connection wires
    gen_inst_wire(table, fswreg_inst)

    fswreg_inst.write("swreg #(ADDR_W, DATA_W) swreg_inst (\n")
    gen_portmap(table, fswreg_inst)
    fswreg_inst.write('\t`include "iob_s_portmap.vh"\n')
    fswreg_inst.write('\t`include "iob_clkrst_portmap.vh"')
    fswreg_inst.write("\n);\n")

    #
    # SWREG MODULE
    #

    fswreg_gen = open(f"{out_dir}/{top}_swreg_gen.v", "w")
    fswreg_gen.write("//This file was generated by script mkregs.py\n\n")

    # time scale
    fswreg_gen.write("`timescale 1ns / 1ps\n\n")

    # declaration
    fswreg_gen.write("module swreg\n")

    # parameters
    fswreg_gen.write("#(\n")
    fswreg_gen.write("\tparameter ADDR_W = 0,\n")
    fswreg_gen.write("\tparameter DATA_W = 0\n")
    fswreg_gen.write(")\n")
    fswreg_gen.write("(\n")

    # ports
    gen_port(table, fswreg_gen)
    fswreg_gen.write('\t`include "iob_s_port.vh"\n')
    fswreg_gen.write('\t`include "iob_clkrst_port.vh"\n')
    fswreg_gen.write(");\n\n")

    # register logic
    has_addr_r = 0
    for row in table:
        if row['rw_type'] == 'W':
            # write register
            gen_wr_reg(row, fswreg_gen)
        else:
            # read register
            gen_rd_reg(row, fswreg_gen)
            # address register
            if not has_addr_r:
                has_addr_r = 1
                fswreg_gen.write("//address register\n")
                fswreg_gen.write(f"`IOB_WIRE(addr_r, {core_addr_w})\n")
                fswreg_gen.write(f"iob_reg #({core_addr_w}, 0) addr_r0 (clk_i, rst_i, 1'b0, iob_valid_i, iob_addr_i, addr_r);\n\n")

    #
    # COMBINATORIAL RESPONSE SWITCH
    #

    # use variables to compute response
    fswreg_gen.write(f"\n`IOB_VAR(rdata_int, 8*`IOB_NBYTES)\n")
    fswreg_gen.write("`IOB_VAR(rvalid_int, 1)\n")
    fswreg_gen.write("`IOB_VAR(wready_int, 1)\n")
    fswreg_gen.write("`IOB_VAR(rready_int, 1)\n")
    fswreg_gen.write("`IOB_WIRE(ready_int, 1)\n\n")

    fswreg_gen.write("`IOB_COMB begin\n\n")

    # response defaults
    fswreg_gen.write("\twready_int = 1'b0;\n")
    fswreg_gen.write("\trready_int = 1'b0;\n")
    fswreg_gen.write("\trdata_int = 0;\n")
    fswreg_gen.write("\trvalid_int = 1'b0;\n\n")

    # update responses
    for row in table:
        reg = row['name']
        reg_addr = row['addr']
        # compute rdata and rvalid
        if row['rw_type'] == 'R':
            # get rdata and rvalid
            fswreg_gen.write(f"\tif( `IOB_WORD_ADDR(addr_r) >= `IOB_WORD_ADDR({reg_addr}) && `IOB_WORD_ADDR(addr_r) < `IOB_WORD_CADDR({reg_addr} + (1'b1<<{row['addr_w']})) )\n")
            # get rdata
            if row['autologic']:
                fswreg_gen.write(f"\t\trdata_int = rdata_int | ({reg}_r << (8*`IOB_BYTE_OFFSET({reg_addr})));\n")
            else:
                fswreg_gen.write(f"\t\trdata_int = rdata_int | ({reg}_i << (8*`IOB_BYTE_OFFSET({reg_addr})));\n")
            # get rvalid
            fswreg_gen.write(f"\t\trvalid_int = rvalid_int | {reg}_rvalid_i;\n")
            # get rready
            fswreg_gen.write(f"\tif( `IOB_WORD_ADDR(iob_addr_i) >= `IOB_WORD_ADDR({reg_addr}) && `IOB_WORD_ADDR(iob_addr_i) < `IOB_WORD_CADDR({reg_addr} + (1'b1<<{row['addr_w']})) ) \n")
            fswreg_gen.write(f"\t\trready_int = ready_int | {reg}_ready_i;\n")
        else:
            # get wready
            fswreg_gen.write(f"\tif( `IOB_WORD_ADDR(iob_addr_i) >= `IOB_WORD_ADDR({reg_addr}) && `IOB_WORD_ADDR(iob_addr_i) < `IOB_WORD_CADDR({reg_addr} + (1'b1<<{row['addr_w']})) ) \n")
            fswreg_gen.write(f"\t\twready_int = ready_int | {reg}_ready_i;\n")

    fswreg_gen.write("end\n\n")

    # convert computed variables to signals
    fswreg_gen.write("assign ready_int = iob_wstrb_i? wready_int: rready_int;\n")
    fswreg_gen.write("`IOB_VAR2WIRE(ready_int, iob_ready_o)\n")
    fswreg_gen.write("`IOB_VAR2WIRE(rdata_int, iob_rdata_o)\n")
    fswreg_gen.write("`IOB_VAR2WIRE(rvalid_int, iob_rvalid_o)\n\n")

    fswreg_gen.write("endmodule\n")
    fswreg_gen.close()
    fswreg_inst.close()


def write_hwheader(table, out_dir, top):
    fswreg_def = open(f"{out_dir}/{top}_swreg_def.vh", "w")
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


# Get C type from swreg nbytes
# uses unsigned int types from C stdint library
def swreg_type(reg, nbytes):
    type_dict = {1: "uint8_t", 2: "uint16_t", 4: "uint32_t", 8: "uint64_t"}
    try:
        type_try = type_dict[nbytes]
    except KeyError:
        print(f"Error: register {reg} has invalid number of bytes {nbytes}.")
    return type_try


def write_swheader(table, out_dir, top):
    fswhdr = open(f"{out_dir}/{top}_swreg.h", "w")

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
            addr_arg = ""
            if row['addr_w'] / row['nbytes'] > 1:
                addr_arg = ", int addr"
            fswhdr.write(f"void {core_prefix}SET_{reg}({sw_type} value{addr_arg});\n")

    fswhdr.write("\n// Core Getters\n")
    for row in table:
        reg = row['name']
        if row["rw_type"] == "R":
            sw_type = swreg_type(reg, row['nbytes'])
            addr_arg = ""
            if row['addr_w'] / row['nbytes'] > 1:
                addr_arg = "int addr"
            fswhdr.write(f"{sw_type} {core_prefix}GET_{reg}({addr_arg});\n")

    fswhdr.write(f"\n#endif // H_{core_prefix}_SWREG_H\n")

    fswhdr.close()


def write_sw_emb(table, out_dir, top):
    fsw = open(f"{out_dir}/{top}_swreg_emb.c", "w")
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
            addr_arg = ""
            addr_arg = ""
            addr_shift = ""
            if row['addr_w'] / row['nbytes'] > 1:
                addr_arg = ", int addr"
                addr_shift = f" + (addr << {int(log(row['nbytes'], 2))})"
            fsw.write(f"void {core_prefix}SET_{reg}({sw_type} value{addr_arg}) {{\n")
            fsw.write(f"\t(*( (volatile {sw_type} *) ( (base) + ({core_prefix}{reg}){addr_shift}) ) = (value));\n")
            fsw.write("}\n\n")
    fsw.write("\n// Core Getters\n")
    for row in table:
        reg = row['name']
        if row["rw_type"] == "R":
            sw_type = swreg_type(reg, row['nbytes'])
            addr_arg = ""
            addr_shift = ""
            if row['addr_w'] / row['nbytes'] > 1:
                addr_arg = "int addr"
                addr_shift = f" + (addr << {int(log(row['nbytes'], 2))})"
            fsw.write(f"{sw_type} {core_prefix}GET_{reg}({addr_arg}) {{\n")
            fsw.write(f"\treturn (*( (volatile {sw_type} *) ( (base) + ({core_prefix}{reg}){addr_shift}) ));\n")
            fsw.write("}\n\n")
    fsw.close()


# Calculate next aligned address
def align_addr(current_addr, reg_nbytes):
    if current_addr % reg_nbytes != 0:
        current_addr = current_addr + (reg_nbytes - (current_addr % reg_nbytes))
    return current_addr


def check_address_alignment(table):
    for row in table:
        if row['addr'] % row['nbytes'] != 0:
            sys.exit(f"Error: address {row['addr']} for {row['nbytes']}-byte data {row['name']} is not aligned")
    return


def check_address_overlapping(table, rw_type):
    # get registers of specific type
    type_regs = []
    for reg in table:
        if reg['rw_type'] == rw_type:
            type_regs.append(reg)
    if not type_regs:
        return

    # sort regs by address
    type_regs.sort(key=lambda i: i['addr'])
    for i in range(len(type_regs) - 1):
        reg_addr_end = type_regs[i]['addr'] + 2**type_regs[i]['addr_w'] - 1
        if reg_addr_end >= type_regs[i+1]['addr']:
            sys.exit(f"Error: {type_regs[i]['name']} and {type_regs[i+1]['name']} registers are overlapped for {rw_type} type")


# Calculate address
def calc_swreg_addr(table):
    read_addr = 0
    write_addr = 0

    # Assign manual addresses
    for row in table:
        if row['addr'] >= 0:
            reg_addr = row['addr']
            reg_offset = 2**row['addr_w']
            if row['rw_type'] == "R" and read_addr <= reg_addr:
                read_addr = reg_addr + reg_offset
            elif row['rw_type'] == "W" and write_addr <= reg_addr:
                write_addr = reg_addr + reg_offset

    # Assign automatic addresses
    for row in table:
        reg_addr = row['addr']
        reg_nbytes = row['nbytes']
        reg_offset = 2**row['addr_w']
        if reg_addr < 0:
            if row['rw_type'] == "R":
                read_addr = align_addr(read_addr, reg_nbytes)
                row['addr'] = read_addr
                read_addr = read_addr + reg_offset
            elif row['rw_type'] == "W":
                write_addr = align_addr(write_addr, reg_nbytes)
                row['addr'] = write_addr
                write_addr = write_addr + reg_offset
    max_addr = max(read_addr, write_addr)
    global core_addr_w
    core_addr_w = max(int(ceil(log(max_addr, 2))), 1)

    check_address_alignment(table)
    check_address_overlapping(table, "R")
    check_address_overlapping(table, "W")

    return table

# return table: list of swreg dictionaries based on toml configuration
def swreg_list(toml_dict):
    table = []
    for __, regs in toml_dict.items():
        for reg in regs[0].items():
            table.append({"name":reg[0], "nbytes":ceil(int(reg[1]['nbits'])/8)} | reg[1])

    # calculate address field
    table = calc_swreg_addr(table)

    return table

# process swreg configuration
def swreg_proc(toml_dict, hwsw, top, out_dir):
    table = swreg_list(toml_dict)
    if hwsw == "HW":
        write_hwheader(table, out_dir, top)
        write_hwcode(table, out_dir, top)
    elif hwsw == "SW":
        write_swheader(table, out_dir, top)
        write_sw_emb(table, out_dir, top)


def main():
    quit
    # parse command line
    args = parse_arguments()

    # load input file
    config_file_name = f"{args.PATH}/mkregs.toml"
    try:
        fin = open(config_file_name, "rb")
    except FileNotFoundError:
        print(f"Could not open {config_file_name}")
        quit()
    toml_dict = tomli.load(fin)
    fin.close()
    swreg_proc(toml_dict, args.hwsw, args.TOP, args.out_dir)


if __name__ == "__main__":
    main()
