#!/usr/bin/env python3
#
#    mkregs.py: build Verilog software accessible registers and software getters and setters
#

import sys
from parse import parse, search
import math
from verilog2tex import header_parse


def print_usage():

    usage_str = """Usage: ./mkregs.py TOP PATH {HW|SW} [vh_files] [--help]
        TOP:        Top/core module name
        PATH:       Path to mkregs.conf file
        {HW|SW}:    HW: generate the hardware files
                    SW: generate the software files
        [vh_files]: (SW only) paths to .vh files used to extract macro values
        [--help]:   (optional) display detailed help information"""

    print(usage_str)


def print_help():
    help_str = """Detailed Help:
        mkregs.py script generates hardware logic and software drivers to
        interface core with CPU.

    General operation:
        1. Read ./<PATH>/mkregs.conf file with information about the software
        accessible registers and memories.
        2. Generate boilerplate code for integration.
        [HW files]: generates <TOP>_swreg_def.vh and <TOP>_swreg_gen.vh files.
            <TOP>_swreg_def.vh contains verilog definitions for the generated
            registers and memories.
            <TOP>_swreg_gen.vh contains verilog instantiation and logic for the
            generated registers and memories.
        [SW files]: generates <TOP>_swreg.h and <TOP>_swreg_emb.c files.
            <TOP>_swreg.h is a C header with addressing, corresponding C data
            types getters and setters for the generated registers and memories.
            <TOP>_swreg_emb.c is a C source file with the implementation for the
            setters and getters for the embedded platform.
            Note: for PC-Emulation, the core developer needs to implement the
            setters and getters defined in <TOP>_swreg.h.

    mkregs.conf file:
        The configuration file supports the following types of register and
        memory declarations:

        SOFTWARE IOB_ACCESSIBLE IOB_REGISTERS:
            IOB_SWREG_R(NAME, WIDTH, RST_VAL)
                sw can read NAME at address NAME_ADDR
                hw can assign wire NAME
            IOB_SWREG_W(NAME, WIDTH, RST_VAL)
                sw can write NAME at address NAME_ADDR
                hw can use signal NAME

        SOFTWARE IOB_ACCESSIBLE IOB_MEMORIES:
            IOB_SWMEM_R(NAME, WIDTH, ADDR_W)
                sw can read NAME[0-(2^ADDR_W-1)]
                hw can use:
                    wire NAME_addr_int;
                    wire NAME_ren_int;
                hw can assign
                    wire NAME_rdata_int;
            IOB_SWMEM_W(NAME, WIDTH, ADDR_W)
                sw can write NAME[0-(2^ADDR_W-1)]
                hw can use:
                    wire NAME_addr_int;
                    wire NAME_wdata_int;
                    wire NAME_wstrb_int;

    Example mkregs.conf file:
    //START_SWREG_TABLE example_core
    IOB_SWREG_W(CORE_RUN, 1, 0) //Brief description.
    IOB_SWMEM_W(CORE_WR_BUFFER, 8, 12) //Core write buffer
    IOB_SWREG_R(CORE_DONE, 1, 0) //Done signal.
    IOB_SWMEM_R(CORE_READ_BUFFER, 16, 10)//Core read buffer"""

    print(help_str)


def has_mem_type(table, mem_type_list=["W", "R"]):
    for reg in table:
        if reg["reg_type"] == "MEM":
            if reg["rw_type"] in mem_type_list:
                return 1
    return 0


def gen_mem_wires(table, fout):
    fout.write("\n//mem wires\n")
    for reg in table:
        if reg["reg_type"] == "MEM":
            data_w = int(reg['nbytes'])*8
            fout.write(f"`IOB_WIRE({reg['name']}_addr, {reg['addr_w']})\n")
            if reg["rw_type"] == "W":
                fout.write(f"`IOB_VAR({reg['name']}_wdata, {data_w})\n")
                fout.write(f"`IOB_WIRE({reg['name']}_wstrb, {reg['nbytes']})\n")
            else:
                fout.write(f"`IOB_WIRE({reg['name']}_rdata, {data_w})\n")
                fout.write(f"`IOB_WIRE({reg['name']}_ren, 1)\n")
                fout.write(f"`IOB_VAR({reg['name']}_rdata_int, 32)\n")
            fout.write("\n")
    fout.write("\n")


def get_addr_block(table):
    for reg in table:
        if reg["reg_type"] == "MEM":
            return reg["addr"]
    return 0


def gen_mem_write_hw(table, fout):
    fout.write("\n//mem write logic\n")
    for reg in table:
        if reg["reg_type"] == "MEM" and reg['rw_type'] == "W":
            fout.write(f"`IOB_WIRE2WIRE(address[{reg['addr_w']}-1:0], {reg['name']}_addr)\n")
            # get correct bytes from aligned wdata
            num_splits = int(4/int(reg['nbytes']))
            num_splits_w = int(math.log(num_splits, 2))
            fout.write("always @* begin\n")
            if num_splits_w == 0:
                fout.write(f"{reg['name']}_wdata = wdata;\n")
            else:
                fout.write(f"    case(address[0+:{num_splits_w}])\n")
                data_w = int(reg['nbytes'])*8
                for i in range(num_splits-1):
                    fout.write(f"        {i}: {reg['name']}_wdata = wdata[{data_w*i}+:{data_w}];\n")
                fout.write(f"        default: {reg['name']}_wdata = wdata[{data_w*(num_splits-1)}+:{data_w}];\n")
                fout.write("    endcase\n")
            fout.write("end\n")
            addr_block_w = str(int(math.log(int(get_addr_block(table)), 2)))
            fout.write(f"`IOB_WIRE2WIRE((valid & ( {{address[ADDR_W-1:{addr_block_w}], {{{addr_block_w}{{1'b0}}}}}} == {reg['addr']})) ? {{{reg['nbytes']}{{|wstrb}}}} : {{{reg['nbytes']}{{1'b0}}}}, {reg['name']}_wstrb)")


def gen_mem_read_hw(table, fout):
    # Do nothing if there are no read memories
    if has_mem_type(table, ["R"]) == 0:
        return

    addr_block_w = str(int(math.log(int(get_addr_block(table)), 2)))
    fout.write("\n//mem read logic\n")
    fout.write("`IOB_WIRE(addr_offset_reg, 2)\n")
    fout.write("iob_reg #(2) addr_offset_reg (clk, rst, 1'b0, 1'b0, 1'b0, 1'b1, address[0+:2], addr_offset_reg);\n\n")
    for reg in table:
        if reg["reg_type"] == "MEM" and reg["rw_type"] == "R":
            fout.write(f"`IOB_WIRE2WIRE(address[{reg['addr_w']}-1:0], {reg['name']}_addr)\n")
            fout.write(f"`IOB_WIRE2WIRE((valid & ( {{address[ADDR_W-1:{addr_block_w}], {{ {addr_block_w} {{1'b0}} }} }} == {reg['addr']})), {reg['name']}_ren)\n")
            # align MEM rdata
            num_splits = int(4/int(reg['nbytes']))
            num_splits_w = int(math.log(num_splits, 2))
            fout.write("always @* begin\n")
            if num_splits_w == 0:
                fout.write(f"{reg['name']}_rdata_int = {reg['name']}_rdata;\n")
            else:
                fout.write(f"    case(addr_offset_reg[0+:{num_splits_w}])\n")
                data_w = int(reg['nbytes'])*8
                for i in range(num_splits-1):
                    if i == 0:
                        fout.write(f"        {i}: {reg['name']}_rdata_int = {reg['name']}_rdata;\n")
                    else:
                        fout.write(f"        {i}: {reg['name']}_rdata_int = {{{reg['name']}_rdata, {data_w*i}'b0}};\n")
                fout.write(f"        default: {reg['name']}_rdata_int = {{{reg['name']}_rdata, {data_w*(num_splits-1)}'b0}};\n")
                fout.write("    endcase\n")
            fout.write("end\n")

    # switch case for mem reads
    fout.write("\n`IOB_WIRE(mem_address, ADDR_W)\n")
    # Delay SWMEM_R address 1 cycle to wait for rdata
    fout.write(f"iob_reg #(ADDR_W) address_reg (clk, rst, {{ADDR_W{{1'b0}}}}, 1'b0, {{ADDR_W{{1'b0}}}}, 1'b1, {{address[ADDR_W-1:{addr_block_w}], {{{addr_block_w}{{1'b0}}}}}}, mem_address);\n")
    fout.write("always @* begin\n")
    fout.write("\tcase(mem_address)\n")
    for reg in table:
        if reg["reg_type"] == "MEM" and reg["rw_type"] == "R":
            fout.write(f"\t\t{reg['addr']}: mem_rdata_int = {reg['name']}_rdata_int;\n")
    fout.write("\t\tdefault: mem_rdata_int = 1'b0;\n")
    fout.write("\tendcase\n")
    fout.write("end\n")


def write_hw(table, regfile_name):

    fout = open(regfile_name + "_gen.vh", "w")

    fout.write("//This file was generated by script mkregs.py\n\n")

    fout.write("\n\n//write registers\n")
    for row in table:
        if row["reg_type"] == "REG" and row['rw_type'] == "W":
            addr_offset = int(row['addr']) % 4
            reg_w = int(row['nbytes']) * 8
            fout.write(f"`IOB_WIRE({row['name']}_en, 1)\n")
            fout.write(f"`IOB_WIRE2WIRE((valid & (|wstrb[{addr_offset}+:{row['nbytes']}]) & (address == {row['addr']}, {row['name']}_en)\n")
            fout.write(f"`IOB_WIRE({row['name']}_wdata, {reg_w})\n")
            fout.write(f"`IOB_WIRE2WIRE(wdata[{8*addr_offset}+:{reg_w}], {row['name']}_wdata)\n\n")


    fout.write("\n\n//read register logic\n")
    fout.write("`IOB_VAR(rdata_int, DATA_W)\n")
    fout.write("`IOB_WIRE(rdata_int2, DATA_W)\n")
    fout.write(f"iob_reg #(DATA_W) read_reg (clk, rst, {{DATA_W{{1'b0}}}}, 1'b0, {{DATA_W{{1'b0}}}}, valid, rdata_int, rdata_int2);\n")

    # if read memory present then add mem_rdata_int
    if has_mem_type(table, ["R"]):
        fout.write("//Select read data from registers or memory\n")
        fout.write("`IOB_VAR(mem_rdata_int, DATA_W)\n")
        fout.write("`IOB_WIRE(mem_read_sel, 1)\n")
        # Register condition for SWMEM_R access
        addr_block_w = str(int(math.log(int(get_addr_block(table)), 2)))
        fout.write(f"iob_reg #(1) mem_read_sel_reg (clk, rst, 1'b0, 1'b0, 1'b0, 1'b1, (valid & (wstrb == 0) & (|address[ADDR_W-1:{addr_block_w}])), mem_read_sel);\n")
        # skip rdata_int2 delay for memory read accesses
        fout.write("`IOB_VAR2WIRE((mem_read_sel) ? mem_rdata_int : rdata_int2, rdata)\n\n")
    else:
        fout.write("`IOB_VAR2WIRE(rdata_int2, rdata)\n\n")

    for row in table:
        if row["reg_type"] == "REG" and row['rw_type'] == "R":
            fout.write(f"`IOB_WIRE({row['name']}_rdata, {int(row['nbytes']) * 8})\n")

    fout.write("\nalways @* begin\n")
    fout.write("   case(address)\n")

    for row in table:
        if row["reg_type"] == "REG" and row["rw_type"] == "R":
            # align rdata according to register address
            align_offset = int(row['addr']) % 4
            if align_offset == 0:
                rdata_str = f"{row['name']}_rdata"
            else:
                rdata_str = f"{{{row['name']}_rdata, {align_offset*8}'b0}}"
            fout.write(f"     {row['addr']}: rdata_int = {rdata_str};\n")

    fout.write("     default: rdata_int = 1'b0;\n")
    fout.write("   endcase\n")
    fout.write("end\n")

    # ready signal
    fout.write(f"iob_reg #(1) valid_reg (clk, rst, 1'b0, 1'b0, 1'b0, 1'b1, valid, ready);\n")

    # memory section
    if has_mem_type(table):
        gen_mem_wires(table, fout)
        gen_mem_write_hw(table, fout)
        gen_mem_read_hw(table, fout)

    fout.close()


def get_core_addr_w(table):
    max_addr = 0
    max_addr_from_mem = 0
    for reg in table:
        if int(reg["addr"]) > max_addr:
            max_addr = int(reg["addr"])
            if reg["reg_type"] == "MEM":
                max_addr_from_mem = 1
            else:
                max_addr_from_mem = 0

    if max_addr_from_mem:
        max_addr = max_addr + int(get_addr_block(table))

    hw_max_addr = (max_addr) + 1

    addr_w = int(math.ceil(math.log(hw_max_addr, 2)))
    return addr_w


def write_hwheader(table, regfile_name):

    fout = open(regfile_name + "_def.vh", "w")

    fout.write("//This file was generated by script mkregs.py\n\n")

    fout.write("//address width\n")
    fout.write(f"`define {regfile_name}_ADDR_W {get_core_addr_w(table)}\n\n")

    fout.write("//address macros\n")
    fout.write("//SWREGs\n")

    for row in table:
        if row["reg_type"] == "REG":
            fout.write(f"`define {row['name']}_ADDR {int(row['addr'])}\n")
    fout.write("//SWMEMs\n")
    for row in table:
        if row["reg_type"] == "MEM":
            fout.write(f"`define {row['name']}_ADDR {int(row['addr'])}\n")

    fout.write("\n//register/mem data width\n")
    for row in table:
        fout.write(f"`define {row['name']}_W {int(row['nbytes'])*8}\n")

    fout.write("\n//mem address width\n")
    for row in table:
        if row["reg_type"] == "MEM":
            fout.write(f"`define {row['name']}_ADDR_W {row['addr_w']}\n")

    fout.close()


# Read vh files to get non-literal widths
def get_defines():
    # .vh file lines
    vh = []

    if len(sys.argv) > 4:
        i = 4
        while i < len(sys.argv) and -1 < sys.argv[i].find(".vh"):
            fvh = open(sys.argv[i], "r")
            vh = [*vh, *fvh.readlines()]
            fvh.close()
            i = i + 1

    defines = {}
    # parse headers if any
    if vh:
        header_parse(vh, defines)

    return defines


# Get C type from swreg width
# uses unsigned int types from C stdint library
# width: SWREG width
def swreg_type(width, defines):
    # Check if width is a number string (1, 8, 15, etc)
    try:
        width_int = int(width)
    except ValueError:
        # width is a parameter or macro (example: DATA_W, ADDR_W)
        eval_str = width.replace("`", "").replace(",", "")
        for key, val in defines.items():
            eval_str = eval_str.replace(str(key), str(val))
        try:
            width_int = int(eval_str)
        except ValueError:
            # eval_str has undefined parameters: use default value
            width_int = 32

    if width_int < 1:
        print(f"MKREGS: invalid SWREG width value {width}.")
        width_int = 32

    type_dict = {8: "uint8_t", 16: "uint16_t", 32: "uint32_t", 64: "uint64_t"}
    default_width = "uint64_t"

    # next 8*2^k big enough to store width
    next_pow2 = 2 ** (math.ceil(math.log2(math.ceil(width_int / 8))))
    sw_width = 8 * next_pow2

    return type_dict.get(sw_width, default_width)


def write_swheader(table, regfile_name, core_prefix, defines):

    fout = open(regfile_name + ".h", "w")

    fout.write("//This file was generated by script mkregs.py\n\n")
    fout.write(f"#ifndef H_IOB_{core_prefix}_SWREG_H\n")
    fout.write(f"#define H_IOB_{core_prefix}_SWREG_H\n\n")
    fout.write("#include <stdint.h>\n\n")

    fout.write("//register address mapping\n")
    for row in table:
        if row["reg_type"] == "REG":
            fout.write(f"#define {row['name']} {row['addr']}\n")

    fout.write("//memory address mapping\n")
    for row in table:
        if row["reg_type"] == "MEM":
            fout.write(f"#define {row['name']} {row['addr']}\n")

    fout.write("\n// Base Address\n")
    fout.write("static int base;\n")
    fout.write(f"void {core_prefix}_INIT_BASEADDR(uint32_t addr);\n")

    fout.write("\n// Core Setters\n")
    for row in table:
        read_write = row["rw_type"]
        if read_write == "W":
            parsed_name = row['name'].split("_", 1)[1]
            sw_type = swreg_type(row['width'], defines)
            if row["reg_type"] == "REG":
                fout.write(f"void {core_prefix}_SET_{parsed_name}({sw_type} value);\n")
            elif row["reg_type"] == "MEM":
                addr_type = swreg_type(row['addr_w'], defines)
                fout.write(f"void {core_prefix}_SET_{parsed_name}({addr_type} addr, {sw_type} value);\n")

    fout.write("\n// Core Getters\n")
    for row in table:
        read_write = row["rw_type"]
        if read_write == "R":
            parsed_name = row['name'].split("_", 1)[1]
            sw_type = swreg_type(row['width'], defines)
            if row["reg_type"] == "REG":
                fout.write(f"{sw_type} {core_prefix}_GET_{parsed_name}();\n")
            elif row["reg_type"] == "MEM":
                addr_w = row["addr_w"]
                addr_type = swreg_type(addr_w, defines)
                fout.write(f"{sw_type} {core_prefix}_GET_{parsed_name}({addr_type} addr);\n")

    fout.write(f"\n#endif // H_IOB_{core_prefix}_SWREG_H\n")

    fout.close()


def write_sw_emb(table, regfile_name, core_prefix, defines):

    fout = open(regfile_name + "_emb.c", "w")

    fout.write("//This file was generated by script mkregs.py\n\n")

    swheader_name = regfile_name + ".h"
    fout.write(f'#include "{swheader_name}"\n\n')

    fout.write("\n// Base Address\n")
    fout.write(f"void {core_prefix}_INIT_BASEADDR(uint32_t addr) {{\n")
    fout.write("\tbase = addr;\n")
    fout.write("}\n")

    fout.write("\n// Core Setters\n")
    for row in table:
        read_write = row["rw_type"]
        if read_write == "W":
            parsed_name = row['name'].split("_", 1)[1]
            sw_type = swreg_type(row['width'], defines)
            if row["reg_type"] == "REG":
                fout.write(f"void {core_prefix}_SET_{parsed_name}({sw_type} value) {{\n")
                fout.write(f"\t(*( (volatile {sw_type} *) ( (base) + ({row['name']}) ) ) = (value));\n")
                fout.write("}\n\n")
            elif row["reg_type"] == "MEM":
                addr_type = swreg_type(row['addr_w'], defines)
                fout.write(f"void {core_prefix}_SET_{parsed_name}({addr_type} addr, {sw_type} value) {{\n")
                fout.write(f"\t(*( (volatile {sw_type} *) ( (base) + ({row['name']}) + (addr<<2) ) ) = (value));\n")
                fout.write("}\n\n")

    fout.write("\n// Core Getters\n")
    for row in table:
        read_write = row["rw_type"]
        if read_write == "R":
            parsed_name = row['name'].split("_", 1)[1]
            sw_type = swreg_type(row['width'], defines)
            if row["reg_type"] == "REG":
                fout.write(f"{sw_type} {core_prefix}_GET_{parsed_name}() {{\n")
                fout.write(f"\treturn (*( (volatile {sw_type} *) ( (base) + ({row['name']}) ) ));\n")
                fout.write("}\n\n")
            elif row["reg_type"] == "MEM":
                addr_type = swreg_type(row['addr_w'], defines)
                fout.write(f"{sw_type} {core_prefix}_GET_{parsed_name}({addr_type} addr) {{\n")
                fout.write(f"\treturn (*( (volatile {sw_type} *) ( (base) + ({row['name']}) + (addr<<2) ) ));\n")
                fout.write("}\n\n")

    fout.close()


# Obtain REG only fields
def swreg_parse_reg(swreg_flds, parsed_line):
    # DEFAULT VALUE
    swreg_flds["default_value"] = parsed_line[4]
    return swreg_flds


# Obtain MEM only fields
def swreg_parse_mem(swreg_flds, parsed_line):
    # ADDR_W
    swreg_flds["addr_w"] = parsed_line[4]
    return swreg_flds


# Calculate next power of 2 after value (inclusive)
def calc_next_pow2(value):
    if value < 1:
        return 0
    else:
        return int(2 ** math.ceil(math.log2(value)))


def align_addr(addr, reg):
    aligned_addr = addr
    reg_w = int(reg["nbytes"])
    off_bytes = (addr % reg_w)
    if off_bytes:
        aligned_addr = addr + reg_w - off_bytes

    return aligned_addr


def get_regs_of_type(table, rw_type):
    type_regs = []
    for reg in table:
        if reg['rw_type'] == rw_type:
            type_regs.append(reg)
    return type_regs


def check_overlapped_addresses(table, rw_type):
    type_regs = get_regs_of_type(table, rw_type)
    if not type_regs:
        return

    # sort regs by address
    type_regs.sort(key=lambda i: int(i['addr']))
    for i in range(len(type_regs) - 1):
        reg_addr_end = int(type_regs[i]['addr']) + int(type_regs[i]['nbytes']) - 1
        if reg_addr_end >= int(type_regs[i+1]['addr']):
            print(f"ERROR: {type_regs[i]['name']} and {type_regs[i+1]['name']} registers are overlapped for {rw_type} type")


def check_addresses(table):
    # Check for aligned data
    for reg in table:
        if int(reg['addr']) % int(reg['nbytes']) != 0:
            print(f"ERROR: {reg['name']} register not aligned")

    check_overlapped_addresses(table, "R")
    check_overlapped_addresses(table, "W")

# Calculate REG and MEM addresses
def calc_swreg_addr(table):
    """Calculate REG and MEM addresses.

    Use addresses given by mkregs.conf.
    Addresses with -1 are automatically assigned after last manual address.
    Memories are assigned starting addresses like registers.
    Write and Read addresses are independent.
    Check for address assignment errors:
    Addresses are byte aligned:
        - 1 byte registers can have any address
        - 2 byte registers can have even addresses
        - 4 byte registers can have addresses multiples of 4
    The same address cannot be assigned to multiple read registers/memories.
    The same address cannot be assigned to multiple write registers/memories.
    """
    read_addr = 0
    write_addr = 0

    # Get last manual address for read and write
    for reg in table:
        if int(reg['addr']) >= 0:
            if reg['rw_type'] == "R":
                read_addr = read_addr + int(reg['nbytes'])
            elif reg['rw_type'] == "W":
                write_addr = write_addr + int(reg['nbytes'])
            else:
                print(f"Error: invalid RW type for {reg['name']}")

    # Assign automatic addresses
    reg_addr = 0
    for reg in table:
        if int(reg['addr']) == -1:
            # get rw_type address
            if reg['rw_type'] == "R":
                reg_addr = read_addr
            elif reg['rw_type'] == "W":
                reg_addr = write_addr
            else:
                print(f"Error: invalid RW type for {reg['name']}")
                continue

            reg_addr = align_addr(reg_addr, reg)
            reg['addr'] = str(reg_addr)

            # calculate next available address
            if reg['reg_type'] == "REG":
                reg_addr = reg_addr + int(reg['nbytes'])
            elif reg['reg_type'] == "MEM":
                reg_addr = reg_addr + (int(reg['nbytes']) << int(reg['addr_w']))
            else:
                print(f"Error: invalid REG type for {reg['name']}")

            # update rw_type address
            if reg['rw_type'] == "R":
                read_addr = reg_addr
            elif reg['rw_type'] == "W":
                write_addr = reg_addr
            else:
                print(f"Error: invalid RW type for {reg['name']}")
                continue

    # Check for valid addresses
    check_addresses(table)

    return table


def swreg_get_fields(line):
    """ get direct fields from mkreg.conf line.

    Parse line for SWREG/SWMEM patterns and get key : value pairs for direct
    line fields.
    Parameters
    ----------
    line : str
        String to parse
    Returns
    -------
        None if no matches.
        Dictionary with named fields read from line (except addr field)
            - rw_type: R (read) or W (write)
            - name: register / memory name
            - nbytes: register / memory DATA_W in bytes
            - default_value: reset value
            - addr: register / memory address
            - addr_w: log2(address width of register/memory)
            - wspace: whitespace
            - description: register / memory comment at the end of the line
            - reg_type: register type: REG (register) or MEM (memory)
    """

    # Parse IOB_SWREG_{R|W}(NAME, NBYTES, RST_VAL, ADDR, ADDR_W) // Comment
    result = search("IOB_SWREG_{rw_type}({name},{nbytes},{default_value},{addr},{addr_w}){wspace}//{description}\n", line)

    # Get dictionary of named fields from parse.Result object
    if result:
        swreg_flds = result.named
        # Set reg_type
        if int(swreg_flds["addr_w"]) == 0:
            swreg_flds["reg_type"] = "REG"
        elif int(swreg_flds["addr_w"]) > 0:
            swreg_flds["reg_type"] = "MEM"
        else:
            print("ADDR_W Field: invalid value")
            swreg_flds["reg_type"] = ""
        # Remove whitespace
        for key in swreg_flds:
            swreg_flds[key] = swreg_flds[key].strip(" ").strip("\t")
    else:
        swreg_flds = None

    return swreg_flds


def swreg_parse(code, hwsw, top):
    table = []  # list of swreg dictionaries

    for line in code:
        swreg_flds = swreg_get_fields(line)
        if swreg_flds is None:
            continue

        table.append(swreg_flds)

    # calculate address field
    table = calc_swreg_addr(table)

    # regfile_name = top + "_swreg"
    #
    # if hwsw == "HW":
    #     write_hwheader(table, regfile_name)
    #     write_hw(table, regfile_name)
    #
    # elif hwsw == "SW":
    #     core_prefix = top.upper()
    #     defines = get_defines()
    #     write_swheader(table, regfile_name, core_prefix, defines)
    #     write_sw_emb(table, regfile_name, core_prefix, defines)


def main():

    # parse command line
    if len(sys.argv) < 3:
        print_usage()
        if "--help" in sys.argv:
            print_help()
        quit()
    else:
        top = sys.argv[1]
        path = sys.argv[2]
        hwsw = sys.argv[3]

    # parse input file
    config_file_name = f"{path}/mkregs.conf"
    try:
        fin = open(config_file_name, "r")
    except FileNotFoundError:
        print(f"Could not open {config_file_name}")
        quit()
    defsfile = fin.readlines()
    fin.close()

    swreg_parse(defsfile, hwsw, top)


if __name__ == "__main__":
    main()
