#!/usr/bin/env python3
#
#    mkregs.py: build Verilog software accessible registers and software getters and setters
#

import sys
from parse import parse
import math
from verilog2tex import header_parse


def print_usage():

    usage_str = """Usage: ./mkregs.py [TOP] [HW|SW] [vh_files] [--help]
        [TOP]:      Top/core module name
        [HW|SW]:    HW: generate the hardware files
                    SW: generate the software files
        [vh_files]: (SW only) paths to .vh files used to extract macro values
        [--help]:   (optional) display detailed help information"""

    print(usage_str)


def print_help():
    help_str = """Detailed Help:
        mkregs.py script generates hardware logic and software drivers to
        interface core with CPU.

    General operation:
        1. Read <TOP>.configuration file with information about the software
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

    <TOP>.configuration file:
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

    Example <TOP>.configuration file:
    // Note: No whitespace before declarations
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
            name = reg["name"]
            addr_w = reg["addr_w"]
            width = reg["width"]
            fout.write(f"`IOB_VAR({name}_addr_int, {addr_w})\n")
            if reg["rw_type"] == "W":
                fout.write(f"`IOB_VAR({name}_wdata_int, {width})\n")
                fout.write(f"`IOB_VAR({name}_wstrb_int, {width}/8)\n")
            else:
                fout.write(f"`IOB_VAR({name}_rdata_int, {width})\n")
                fout.write(f"`IOB_VAR({name}_ren_int, 1)\n")
    fout.write("\n")


def get_addr_block(table):
    for reg in table:
        if reg["reg_type"] == "MEM":
            return reg["addr"]
    return 0


def gen_mem_write_hw(table, fout):
    fout.write("\n//mem write logic\n")
    for reg in table:
        if reg["reg_type"] == "MEM":
            if reg["rw_type"] == "W":
                addr = str(int(reg["addr"]) >> 2)
                addr_block_w = str(int(math.log(int(get_addr_block(table)) >> 2, 2)))
                fout.write(f"`IOB_COMB {reg['name']}_addr_int = address[{reg['addr_w']}-1:0];\n")
                fout.write(f"`IOB_COMB {reg['name']}_wdata_int = wdata[{reg['width']}-1:0];\n")
                fout.write(f"`IOB_COMB {reg['name']}_wstrb_int = (valid & ( {{address[ADDR_W-1:{addr_block_w}], {{ {addr_block_w} {{1'b0}} }} }} == {addr})) ? wstrb : {{(DATA_W/8){{1'b0}}}};\n")


def gen_mem_read_hw(table, fout):
    has_mem_reads = 0
    fout.write("\n//mem read logic\n")
    for reg in table:
        if reg["reg_type"] == "MEM":
            if reg["rw_type"] == "R":
                has_mem_reads = 1
                addr = str(int(reg["addr"]) >> 2)
                addr_block_w = str(int(math.log(int(get_addr_block(table)) >> 2, 2)))
                fout.write(f"`IOB_COMB {reg['name']}_addr_int = address[{reg['addr_w']}-1:0];\n")
                fout.write(f"`IOB_COMB {reg['name']}_ren_int = (valid & ( {{address[ADDR_W-1:{addr_block_w}], {{ {addr_block_w} {{1'b0}} }} }} == {addr}));\n")

    # switch case for mem reads
    if has_mem_reads:
        fout.write("`IOB_VAR(mem_address, ADDR_W)\n")
        addr_block_w = str(int(math.log(int(get_addr_block(table)) >> 2, 2)))
        # Delay SWMEM_R address 1 cycle to wait for rdata
        fout.write(f"`IOB_REG_AR(clk, rst, 0, mem_address, {{address[ADDR_W-1:{addr_block_w}], {{ {addr_block_w} {{1'b0}} }} }})\n")
        fout.write("always @* begin\n")
        fout.write("\tcase(mem_address)\n")
        for reg in table:
            if reg["reg_type"] == "MEM":
                if reg["rw_type"] == "R":
                    addr = str(int(reg["addr"]) >> 2)
                    fout.write(f"\t\t{addr}: mem_rdata_int = {reg['name']}_rdata_int;\n")
        fout.write("\t\tdefault: mem_rdata_int = 1'b0;\n")
        fout.write("\tendcase\n")
        fout.write("end\n")


def write_hw(table, regfile_name):

    fout = open(regfile_name + "_gen.vh", "w")

    fout.write("//This file was generated by script mkregs.py\n\n")

    fout.write("\n\n//write registers\n")
    for row in table:
        if row["reg_type"] == "REG":
            if row['rw_type'] == "W":
                fout.write(f"`IOB_VAR({row['name']},{row['width']})\n")
                fout.write(f"`IOB_REG_ARE(clk, rst, {row['default_value']}, valid & wstrb & (address == {int(row['addr']) >> 2}), {row['name']}, wdata[{row['width']}-1:0])\n")
            else:
                fout.write(f"`IOB_WIRE({row['name']}, {row['width']})\n")

    fout.write("\n\n//read registers\n")
    fout.write("`IOB_VAR(rdata_int, DATA_W)\n")
    fout.write("`IOB_VAR(rdata_int2, DATA_W)\n")
    fout.write("`IOB_REG_ARE(clk, rst, 0, valid, rdata_int2, rdata_int)\n")

    # if read memory present then add mem_rdata_int
    if has_mem_type(table, ["R"]):
        fout.write("`IOB_VAR(mem_rdata_int, DATA_W)\n")
        fout.write("`IOB_VAR(mem_read_sel, 1)\n")
        # Register condition for SWMEM_R access
        addr_block_w = str(int(math.log(int(get_addr_block(table)) >> 2, 2)))
        fout.write(f"`IOB_REG_AR(clk, rst, 0, mem_read_sel, (valid & (wstrb == 0) & (|address[ADDR_W-1:{addr_block_w}]) ) )\n")
        # skip rdata_int2 delay for memory read accesses
        fout.write("`IOB_VAR2WIRE((mem_read_sel) ? mem_rdata_int : rdata_int2, rdata)\n\n")
    else:
        fout.write("`IOB_VAR2WIRE(rdata_int2, rdata)\n\n")

    fout.write("always @* begin\n")
    fout.write("   case(address)\n")

    for row in table:
        if row["reg_type"] == "REG":
            if row["rw_type"] == "R":
                fout.write(f"     {int(row['addr']) >> 2}: rdata_int = {row['name']};\n")
            else:
                continue

    fout.write("     default: rdata_int = 1'b0;\n")
    fout.write("   endcase\n")
    fout.write("end\n")

    # ready signal
    fout.write("`IOB_VAR(ready_int, 1)\n")
    fout.write("`IOB_REG_AR(clk, rst, 0, ready_int, valid)\n")
    fout.write("`IOB_VAR2WIRE(ready_int, ready)\n")

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

    hw_max_addr = (max_addr >> 2) + 1

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
            fout.write(f"`define {row['name']}_ADDR {int(row['addr']) >> 2}\n")
    fout.write("//SWMEMs\n")
    for row in table:
        if row["reg_type"] == "MEM":
            fout.write(f"`define {row['name']}_ADDR {int(row['addr']) >> 2}\n")

    fout.write("\n//register/mem data width\n")
    for row in table:
        fout.write(f"`define {row['name']}_W {row['width']}\n")

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


# Calculate REG and MEM addresses
def calc_swreg_addr(table):
    reg_addr = 0

    # REG addresses come first
    for reg in table:
        if reg["reg_type"] == "REG":
            reg["addr"] = str(reg_addr)
            reg_addr = reg_addr + 4

    # register addresses and each memorie is contained in an address block
    addr_block = reg_addr

    for reg in table:
        if reg["reg_type"] == "MEM":
            # Note x4 factor to use software addresses
            addr_block_tmp = 2 ** (int(reg["addr_w"])) * 4
            if addr_block_tmp > addr_block:
                addr_block = addr_block_tmp

    mem_addr = addr_block

    # Assign MEM addresses
    for reg in table:
        if reg["reg_type"] == "MEM":
            reg["addr"] = str(mem_addr)
            mem_addr = mem_addr + addr_block

    return table


def swreg_parse(code, hwsw, top):
    table = []  # name, regtype, rwtype, address, width, default value, description

    for line in code:

        swreg_flds = {}

        swreg_flds_tmp = parse("`IOB_SW{}_{}({},{},{}){}//{}", line)
        if swreg_flds_tmp is None:
            continue  # not a sw reg

        # Common fields for REG and MEM
        # REG_TYPE
        swreg_flds["reg_type"] = swreg_flds_tmp[0]

        # RW_TYPE
        swreg_flds["rw_type"] = swreg_flds_tmp[1]

        # NAME
        swreg_flds["name"] = swreg_flds_tmp[2].strip(" ")

        # WIDTH
        swreg_flds["width"] = swreg_flds_tmp[3]

        # DESCRIPTION
        swreg_flds["description"] = swreg_flds_tmp[6]

        # REG_TYPE specific fields
        if swreg_flds["reg_type"] == "REG":
            swreg_flds = swreg_parse_reg(swreg_flds, swreg_flds_tmp)
        elif swreg_flds["reg_type"] == "MEM":
            swreg_flds = swreg_parse_mem(swreg_flds, swreg_flds_tmp)

        table.append(swreg_flds)

    # calculate address field
    table = calc_swreg_addr(table)

    regfile_name = top + "_swreg"

    if hwsw == "HW":
        write_hwheader(table, regfile_name)
        write_hw(table, regfile_name)

    elif hwsw == "SW":
        core_prefix = top.upper()
        defines = get_defines()
        write_swheader(table, regfile_name, core_prefix, defines)
        write_sw_emb(table, regfile_name, core_prefix, defines)


def main():

    # parse command line
    if len(sys.argv) < 3:
        print_usage()
        if "--help" in sys.argv:
            print_help()
        quit()
    else:
        top = sys.argv[1]
        hwsw = sys.argv[2]

    # parse input file
    config_file_name = top + ".configuration"
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
