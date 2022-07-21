#!/usr/bin/env python3
#
#    mkregs.py: build Verilog software accessible registers and software getters and setters
#

import sys
from parse import parse, search
import math


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
            software accessible registers and memories.
        [SW files]: generates <TOP>_swreg.h and <TOP>_swreg_emb.c files.
            <TOP>_swreg.h is a C header with addressing, corresponding C data
            types getters and setters for the generated registers and memories.
            <TOP>_swreg_emb.c is a C source file with the implementation for the
            setters and getters for the embedded platform.
            Note: for PC-Emulation, the core developer needs to implement the
            setters and getters defined in <TOP>_swreg.h.

    mkregs.conf file:
        The configuration file supports the following register/memory
        declarations:
            IOB_SWREG_R(NAME, NBYTES, RST_VAL, ADDR, ADDR_W) // Description
                sw can read:
                    NAME                 (REG case)
                    NAME[0-(2^ADDR_W-1)] (MEM case)
                hw can use:
                    wire NAME_addr; (MEM only)
                    wire NAME_ren;
                hw can assign
                    wire NAME_rdata;     (Sampled in cycle after valid)
            IOB_SWREG_W(NAME, NBYTES, RST_VAL, ADDR, ADDR_W) // Description
                sw can write:
                    NAME                 (REG case)
                    NAME[0-(2^ADDR_W-1)] (MEM case)
                hw can use:
                    wire NAME_wdata;
                    wire NAME_en;       (REG only)
                    wire NAME_addr;     (MEM only)
                    wire NAME_wstrb;    (MEM only)

    mkregs.conf fields:
    - NAME: Name of software accessible register.
    - NBYTES: Data width in bytes. (Powers of two only: 1, 2, 4, ...)
    - RST_VAL: Reset value. (Only used for documentation)
    - ADDR: Register byte address.
        The ADDR field needs to be a multiple of NBYTES.
        For memories, the ADDR needs to be a multiple of CPU data width in
        bytes.
        ADDR = -1 assigns automatic address to register/memory. The automatic
        addresses are always higher than the manually assigned addresses.
        The read and write addresses are independent. A read register and
        another write register can have the same address.
    - ADDR_W: Address width in bits for register.
        ADDR_W = 0: generates register;
        ADDR_W > 0: generates memory;

    Example mkregs.conf file:
    //START_SWREG_TABLE example_core
    IOB_SWREG_W(CORE_RUN, 1, 0, 2, 0) //Run write register at address 2
    IOB_SWMEM_W(CORE_WR_BUF, 2, 0, 4, 12) //2^12 x 16 bit write mem at addr 4
    IOB_SWREG_R(CORE_DONE, 1, 0, 1, 0) //Done read register at address 1
    IOB_SWMEM_R(CORE_RD_BUF, 4, 0, 4, 10) //2^10 x 4 bit read mem at addr 4
    """

    print(help_str)


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
        eval_str = d_flds[1].strip('`').lstrip(' ').replace("$", "")  # to replace $clog2 with clog2
        for key, val in defines.items():
            eval_str = eval_str.replace(str(key), str(val))

        try:
            value = eval(eval_str)
        except ValueError:
            # eval_str has undefined parameters: use as is
            value = eval_str

        # insert in dictionary
        if name not in defines:
            defines[name] = value


def has_mem_type(table, mem_type_list=["W", "R"]):
    for reg in table:
        if reg["reg_type"] == "MEM":
            if reg["rw_type"] in mem_type_list:
                return 1
    return 0


def get_num_mem_type(table, rw_type):
    num_regs = 0
    for reg in table:
        if reg['reg_type'] == "MEM" and reg['rw_type'] == rw_type:
            num_regs = num_regs + 1
    return num_regs


def calc_mem_addr_w(reg, cpu_nbytes=4):
    cpu_addr_offset = int(math.log2(cpu_nbytes/int(reg['nbytes'])))
    return max(int(reg['addr_w']) - cpu_addr_offset, 0)


def gen_mem_wires(table, fout, cpu_nbytes=4):
    fout.write("\n//mem wires\n")
    for reg in table:
        if reg["reg_type"] == "MEM":
            mem_addr_w = calc_mem_addr_w(reg, cpu_nbytes)
            addr_offset = int(int(reg['addr']) / cpu_nbytes)
            fout.write(f"localparam {reg['name']}_ADDR_OFFSET = {addr_offset};\n")
            if mem_addr_w > 0:
                fout.write(f"`IOB_WIRE({reg['name']}_addr, {mem_addr_w})\n")
            fout.write(f"`IOB_WIRE({reg['name']}_addr_int, DATA_W+1)\n")
            if reg["rw_type"] == "W":
                fout.write(f"`IOB_WIRE({reg['name']}_wdata, DATA_W)\n")
                fout.write(f"`IOB_WIRE({reg['name']}_wstrb, (DATA_W/8))\n")
            else:
                fout.write(f"`IOB_WIRE({reg['name']}_rdata, DATA_W)\n")
                fout.write(f"`IOB_WIRE({reg['name']}_ren, 1)\n")
            fout.write("\n")
    fout.write("\n")


def gen_mem_write_hw(table, fout, cpu_nbytes=4):
    fout.write("\n//mem write logic\n")
    for reg in table:
        if reg["reg_type"] == "MEM" and reg['rw_type'] == "W":
            # cpu word addressing
            mem_addr_w = calc_mem_addr_w(reg, cpu_nbytes)
            fout.write(f"`IOB_WIRE2WIRE((address - {reg['name']}_ADDR_OFFSET), {reg['name']}_addr_int)\n")
            if mem_addr_w > 0:
                fout.write(f"`IOB_WIRE2WIRE({reg['name']}_addr_int[{mem_addr_w}-1:0], {reg['name']}_addr)\n")
            # get correct bytes from aligned wdata
            fout.write(f"`IOB_WIRE2WIRE(wdata, {reg['name']}_wdata)\n")
            fout.write(f"`IOB_WIRE2WIRE((valid & ( {reg['name']}_addr_int[ADDR_W-1:{mem_addr_w}] == 0 ) & (|wstrb)) ? wstrb : {{(DATA_W/8){{1'b0}}}}, {reg['name']}_wstrb)\n")


def gen_mem_read_hw(table, fout, cpu_nbytes=4):
    # Do nothing if there are no read memories
    if has_mem_type(table, ["R"]) == 0:
        return

    fout.write("\n//mem read logic\n")
    for reg in table:
        if reg["reg_type"] == "MEM" and reg["rw_type"] == "R":
            mem_addr_w = calc_mem_addr_w(reg, cpu_nbytes)
            fout.write(f"`IOB_WIRE2WIRE((address - {reg['name']}_ADDR_OFFSET), {reg['name']}_addr_int)\n")
            if mem_addr_w > 0:
                fout.write(f"`IOB_WIRE2WIRE({reg['name']}_addr_int[{mem_addr_w}-1:0], {reg['name']}_addr)\n")
            fout.write(f"`IOB_WIRE2WIRE((valid & ( {reg['name']}_addr_int[ADDR_W-1:{mem_addr_w}] == 0 ) & ~(|wstrb)), {reg['name']}_ren)\n")

    # switch case for mem reads
    num_read_mems = get_num_mem_type(table, "R")
    fout.write(f"`IOB_WIRE(mem_switch_reg, {num_read_mems})\n")
    mem_read_en_concat_str = "}"
    first_reg = 1
    for reg in table:
        if reg['reg_type'] == "MEM" and reg['rw_type'] == "R":
            if first_reg:
                mem_read_en_concat_str = f"{reg['name']}_ren{mem_read_en_concat_str}"
                first_reg = 0
            else:
                mem_read_en_concat_str = f"{reg['name']}_ren,{mem_read_en_concat_str}"

    mem_read_en_concat_str = "{" + mem_read_en_concat_str
    fout.write(f"`IOB_WIRE2WIRE( {mem_read_en_concat_str}, mem_switch)\n")
    # Delay SWMEM_R address 1 cycle to wait for rdata
    fout.write(f"iob_reg #({num_read_mems}) mem_switch_ (clk, rst, {{{num_read_mems}{{1'b0}}}}, 1'b0, {{{num_read_mems}{{1'b0}}}}, 1'b1, mem_switch, mem_switch_reg);\n")
    mem_switch_val = 1
    fout.write("always @* begin\n")
    fout.write("\tcase(mem_switch_reg)\n")
    for reg in table:
        if reg["reg_type"] == "MEM" and reg["rw_type"] == "R":
            fout.write(f"\t\t{mem_switch_val}: mem_rdata_int = {reg['name']}_rdata;\n")
            mem_switch_val = int(mem_switch_val * 2)
    fout.write("\t\tdefault: mem_rdata_int = 1'b0;\n")
    fout.write("\tendcase\n")
    fout.write("end\n")


def get_rdata_cases(table, cpu_nbytes=4):
    """Get rdata_int case lines for read registers

    Concatenates all read registers with the same 32bit address.
    """
    read_regs = []
    rdata_cases = {}
    for reg in table:
        if reg['reg_type'] == "REG" and reg['rw_type'] == "R":
            read_regs.append(reg)

    # sort regs by start address
    read_regs.sort(key=lambda i: int(i['addr']))

    # group regs with same 32 bit address
    for reg in read_regs:
        addr = int(reg['addr'])
        reg_addr = str(math.floor(addr/cpu_nbytes))
        if reg_addr in rdata_cases:
            rdata_cases[reg_addr].append(reg)
        else:
            rdata_cases[reg_addr] = [reg]

    # create rdata_int case strings
    case_strings = []
    for reg_addr, reg_list in rdata_cases.items():
        byte_cnt = 0
        case_str = ""
        for reg in reg_list:
            byte_offset = int(reg['addr']) % 4
            # zero bytes before reg
            while byte_offset > byte_cnt:
                if not case_str:
                    case_str = "8'b0};\n"
                else:
                    case_str = "8'b0, " + case_str
                byte_cnt = byte_cnt + 1
            # append reg rdata
            if not case_str:
                case_str = f"{reg['name']}_rdata}};\n"
            else:
                case_str = f"{reg['name']}_rdata, " + case_str
            byte_cnt = byte_cnt + int(reg['nbytes'])

        case_str = f"        {reg_addr}: rdata_int = {{" + case_str
        case_strings.append(case_str)

    return case_strings


def write_hw(table, regfile_name, cpu_nbytes=4):

    fout = open(regfile_name + "_gen.vh", "w")

    fout.write("//This file was generated by script mkregs.py\n\n")

    fout.write("\n\n//write registers\n")
    for row in table:
        if row["reg_type"] == "REG" and row['rw_type'] == "W":
            addr_offset = int(row['addr']) % 4
            reg_addr = math.floor(int(row['addr'])/cpu_nbytes)
            reg_w = int(row['nbytes']) * 8
            fout.write(f"`IOB_WIRE({row['name']}_en, 1)\n")
            fout.write(f"`IOB_WIRE2WIRE((valid & (|wstrb[{addr_offset}+:{row['nbytes']}]) & (address == {reg_addr})), {row['name']}_en)\n")
            fout.write(f"`IOB_WIRE({row['name']}_wdata, {reg_w})\n")
            fout.write(f"`IOB_WIRE2WIRE(wdata[{8*addr_offset}+:{reg_w}], {row['name']}_wdata)\n\n")

    fout.write("\n\n//read register logic\n")
    fout.write("`IOB_VAR(rdata_int, DATA_W)\n")
    fout.write("`IOB_WIRE(address_reg, ADDR_W)\n")
    fout.write("iob_reg #(ADDR_W) addr_reg (clk, rst, {ADDR_W{1'b0}}, 1'b0, {ADDR_W{1'b0}}, valid, address, address_reg);\n")

    # if read memory present then add mem_rdata_int
    if has_mem_type(table, ["R"]):
        fout.write("//Select read data from registers or memory\n")
        fout.write("`IOB_VAR(mem_rdata_int, DATA_W)\n")
        fout.write("`IOB_WIRE(mem_read_sel_reg, 1)\n")
        num_read_mems = get_num_mem_type(table, "R")
        fout.write(f"\n`IOB_WIRE(mem_switch, {num_read_mems})\n")
        # Register condition for SWMEM_R access
        fout.write("iob_reg #(1) mem_read_sel_ (clk, rst, 1'b0, 1'b0, 1'b0, 1'b1, (valid & (wstrb == 0) & |mem_switch), mem_read_sel_reg);\n")
        # choose between register or memory read data
        fout.write("`IOB_VAR2WIRE((mem_read_sel_reg) ? mem_rdata_int : rdata_int, rdata)\n\n")
    else:
        fout.write("`IOB_VAR2WIRE(rdata_int, rdata)\n\n")

    for row in table:
        if row["reg_type"] == "REG" and row['rw_type'] == "R":
            fout.write(f"`IOB_WIRE({row['name']}_rdata, {int(row['nbytes']) * 8})\n")

    fout.write("\nalways @* begin\n")
    fout.write("   case(address_reg)\n")

    # concatenate rdata wires with same 32 bit address
    rdata_cases = get_rdata_cases(table, cpu_nbytes)
    for rdata_case in rdata_cases:
        fout.write(rdata_case)

    fout.write("     default: rdata_int = 1'b0;\n")
    fout.write("   endcase\n")
    fout.write("end\n")

    # ready signal
    fout.write("iob_reg #(1) valid_reg (clk, rst, 1'b0, 1'b0, 1'b0, 1'b1, valid, ready);\n")

    # memory section
    if has_mem_type(table):
        gen_mem_wires(table, fout)
        gen_mem_write_hw(table, fout)
        gen_mem_read_hw(table, fout)

    fout.close()


def get_core_addr_w(table, cpu_nbytes=4):
    max_addr = 0
    for reg in table:
        # calculate last address of register/memory
        if reg['reg_type'] == "REG":
            last_addr = int(reg['addr']) + int(reg['nbytes'])
        elif reg['reg_type'] == "MEM":
            last_addr = int(reg['addr']) + (int(reg['nbytes']) << int(reg['addr_w']))
        else:
            print(f"Error: {reg['name']} has invalid reg_type {reg['reg_type']}")

        if last_addr > max_addr:
            max_addr = last_addr

    hw_max_addr = math.floor(max_addr/cpu_nbytes)+1

    addr_w = max(int(math.ceil(math.log(hw_max_addr, 2))), 1)
    return addr_w


def write_hwheader(table, regfile_name, cpu_nbytes=4):

    fout = open(regfile_name + "_def.vh", "w")

    fout.write("//This file was generated by script mkregs.py\n\n")

    fout.write("//address width\n")
    fout.write(f"`define {regfile_name}_ADDR_W {get_core_addr_w(table, cpu_nbytes)}\n\n")

    fout.write("//address macros\n")

    fout.write("//Write addresses\n")
    for row in table:
        if row["rw_type"] == "W":
            fout.write(f"`define {row['name']}_ADDR {row['addr']}\n")

    fout.write("//Read Addresses\n")
    for row in table:
        if row["rw_type"] == "R":
            fout.write(f"`define {row['name']}_ADDR {row['addr']}\n")

    fout.write("\n//register/mem data width\n")
    for row in table:
        fout.write(f"`define {row['name']}_W {int(row['nbytes'])*8}\n")

    fout.write("\n//mem address width\n")
    for row in table:
        if row["reg_type"] == "MEM":
            mem_addr_w = calc_mem_addr_w(row, cpu_nbytes)
            fout.write(f"`define {row['name']}_ADDR_W {mem_addr_w}\n")

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


def write_swheader(table, regfile_name, core_prefix, defines, cpu_nbytes=4):

    fout = open(regfile_name + ".h", "w")

    fout.write("//This file was generated by script mkregs.py\n\n")
    fout.write(f"#ifndef H_{core_prefix}_SWREG_H\n")
    fout.write(f"#define H_{core_prefix}_SWREG_H\n\n")
    fout.write("#include <stdint.h>\n\n")

    fout.write("//register/memory address mapping\n")

    fout.write("//Write Addresses\n")
    for row in table:
        if row["rw_type"] == "W":
            fout.write(f"#define {row['name']} {row['addr']}\n")

    fout.write("//Read Addresses\n")
    for row in table:
        if row["rw_type"] == "R":
            fout.write(f"#define {row['name']} {row['addr']}\n")

    fout.write("\n//register/memory data widths (bit)\n")

    fout.write("//Write Register/Memory\n")
    for row in table:
        if row["rw_type"] == "W":
            fout.write(f"#define {row['name']}_W {int(row['nbytes'])*8}\n")

    fout.write("//Read Register/Memory\n")
    for row in table:
        if row["rw_type"] == "R":
            fout.write(f"#define {row['name']}_W {int(row['nbytes'])*8}\n")

    fout.write("\n// Base Address\n")
    fout.write(f"void {core_prefix}_INIT_BASEADDR(uint32_t addr);\n")

    fout.write("\n// Core Setters\n")
    for row in table:
        if row["rw_type"] == "W":
            parsed_name = row['name'].split("_", 1)[1]
            sw_type = swreg_type(row['nbytes'], defines)
            if row["reg_type"] == "REG":
                fout.write(f"void {core_prefix}_SET_{parsed_name}({sw_type} value);\n")
            elif row["reg_type"] == "MEM":
                addr_type = swreg_type(cpu_nbytes, defines)
                fout.write(f"void {core_prefix}_SET_{parsed_name}({addr_type} addr, {sw_type} value);\n")

    fout.write("\n// Core Getters\n")
    for row in table:
        if row["rw_type"] == "R":
            parsed_name = row['name'].split("_", 1)[1]
            sw_type = swreg_type(row['nbytes'], defines)
            if row["reg_type"] == "REG":
                fout.write(f"{sw_type} {core_prefix}_GET_{parsed_name}();\n")
            elif row["reg_type"] == "MEM":
                addr_type = swreg_type(cpu_nbytes, defines)
                fout.write(f"{sw_type} {core_prefix}_GET_{parsed_name}({addr_type} addr);\n")

    fout.write(f"\n#endif // H_{core_prefix}_SWREG_H\n")

    fout.close()


def write_sw_emb(table, regfile_name, core_prefix, defines, cpu_nbytes=4):

    fout = open(regfile_name + "_emb.c", "w")

    fout.write("//This file was generated by script mkregs.py\n\n")

    swheader_name = regfile_name + ".h"
    fout.write(f'#include "{swheader_name}"\n\n')

    fout.write("\n// Base Address\n")
    fout.write("static int base;\n")
    fout.write(f"void {core_prefix}_INIT_BASEADDR(uint32_t addr) {{\n")
    fout.write("\tbase = addr;\n")
    fout.write("}\n")

    fout.write("\n// Core Setters\n")
    for row in table:
        if row["rw_type"] == "W":
            parsed_name = row['name'].split("_", 1)[1]
            sw_type = swreg_type(row['nbytes'], defines)
            if row["reg_type"] == "REG":
                fout.write(f"void {core_prefix}_SET_{parsed_name}({sw_type} value) {{\n")
                fout.write(f"\t(*( (volatile {sw_type} *) ( (base) + ({row['name']}) ) ) = (value));\n")
                fout.write("}\n\n")
            elif row["reg_type"] == "MEM":
                addr_type = swreg_type(cpu_nbytes, defines)
                fout.write(f"void {core_prefix}_SET_{parsed_name}({addr_type} addr, {sw_type} value) {{\n")
                fout.write(f"\t*(((volatile {sw_type} *) (base + {row['name']})) + addr) = value;\n")
                fout.write("}\n\n")

    fout.write("\n// Core Getters\n")
    for row in table:
        if row["rw_type"] == "R":
            parsed_name = row['name'].split("_", 1)[1]
            sw_type = swreg_type(row['nbytes'], defines)
            if row["reg_type"] == "REG":
                fout.write(f"{sw_type} {core_prefix}_GET_{parsed_name}() {{\n")
                fout.write(f"\treturn (*( (volatile {sw_type} *) ( (base) + ({row['name']}) ) ));\n")
                fout.write("}\n\n")
            elif row["reg_type"] == "MEM":
                addr_type = swreg_type(cpu_nbytes, defines)
                fout.write(f"{sw_type} {core_prefix}_GET_{parsed_name}({addr_type} addr) {{\n")
                fout.write(f"\treturn *(((volatile {sw_type} *) (base + {row['name']})) + addr);\n")
                fout.write("}\n\n")

    fout.close()


def align_addr(addr, reg, cpu_nbytes=4):
    aligned_addr = addr
    if reg['reg_type'] == "REG":
        reg_w = int(reg["nbytes"])
    elif reg['reg_type'] == "MEM":
        # memory address aligned with CPU data width
        reg_w = cpu_nbytes
    else:
        print(f"Error: invalid REG type for {reg['name']}")
        return -1
    off_bytes = (addr % reg_w)
    if off_bytes:
        aligned_addr = addr + (reg_w - off_bytes)

    return aligned_addr


def get_regs_of_type(table, rw_type):
    type_regs = []
    for reg in table:
        if reg['rw_type'] == rw_type:
            type_regs.append(reg)
    return type_regs


def check_overlapped_addresses(table, rw_type, cpu_nbytes=4):
    type_regs = get_regs_of_type(table, rw_type)
    if not type_regs:
        return

    # sort regs by address
    type_regs.sort(key=lambda i: int(i['addr']))
    for i in range(len(type_regs) - 1):
        reg_addr_end = int(type_regs[i]['addr']) + calc_reg_addr_space(type_regs[i], cpu_nbytes) - 1
        if reg_addr_end >= int(type_regs[i+1]['addr']):
            print(f"ERROR: {type_regs[i]['name']} and {type_regs[i+1]['name']} registers are overlapped for {rw_type} type")


def check_addresses(table, cpu_nbytes=4):
    # Check for aligned data
    for reg in table:
        if reg['reg_type'] == "REG":
            if int(reg['addr']) % int(reg['nbytes']) != 0:
                print(f"ERROR: {reg['name']} register not aligned")
        elif reg['reg_type'] == "MEM":
            if int(reg['addr']) % cpu_nbytes != 0:
                print(f"ERROR: {reg['name']} memory not aligned with cpu data width")
        else:
            print(f"Error: invalid REG type for {reg['name']}")

    check_overlapped_addresses(table, "R", cpu_nbytes)
    check_overlapped_addresses(table, "W", cpu_nbytes)


def calc_reg_addr_space(reg, cpu_nbytes=4):
    """Calculate REG address space in bytes

    Calculates the number of bytes reserved for addressing the REG.
    """
    addressed_nbytes = -1
    if reg['reg_type'] == "REG":
        addressed_nbytes = int(reg['nbytes'])
    elif reg['reg_type'] == "MEM":
        mem_nbytes = int(reg['nbytes']) << int(reg['addr_w'])
        addressed_nbytes = max(mem_nbytes, cpu_nbytes)
    else:
        print(f"Error: invalid REG type for {reg['name']}")
        addressed_nbytes = -1

    return addressed_nbytes


# Calculate REG and MEM addresses
def calc_swreg_addr(table, cpu_nbytes=4):
    """Calculate REG and MEM addresses.

    Parameters
    ----------
    table : list
        list of register dictionaries.
    cpu_nbytes : int
        CPU data width in bytes. 4 bytes by default.

    Returns
    -------
    table : list
        list of register dictionaries with calculated addresses.

    Use addresses given by mkregs.conf.
    Addresses with -1 are automatically assigned after last manual address.
    Memories are assigned starting multiples of CPU DATA_W.
    Write and Read addresses are independent.
    Check for address assignment errors:
    Addresses are byte aligned:
        - 1 byte registers can have any address
        - 2 byte registers can have even addresses
        - 4 byte registers can have addresses multiples of 4
    The same address cannot be assigned to multiple read registers/memories.
    The same address cannot be assigned to multiple write registers/memories.
    Memory address range reserve a space multiple of CPU DATA_W.
    """
    read_addr = 0
    write_addr = 0

    # Get largest manual address for read and write
    for reg in table:
        if int(reg['addr']) >= 0:
            reg_addr = int(reg['addr'])
            reg_nbytes = int(reg['nbytes'])
            if reg['rw_type'] == "R" and read_addr <= reg_addr:
                read_addr = reg_addr + reg_nbytes
            elif reg['rw_type'] == "W" and write_addr <= reg_addr:
                write_addr = reg_addr + reg_nbytes

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

            reg_addr = align_addr(reg_addr, reg, cpu_nbytes)
            reg['addr'] = str(reg_addr)

            # calculate next available address
            reg_addr = reg_addr + calc_reg_addr_space(reg, cpu_nbytes)

            # update rw_type address
            if reg['rw_type'] == "R":
                read_addr = reg_addr
            elif reg['rw_type'] == "W":
                write_addr = reg_addr
            else:
                print(f"Error: invalid RW type for {reg['name']}")
                continue

    # Check for valid addresses
    check_addresses(table, cpu_nbytes)

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


def swreg_parse(code, hwsw, top, cpu_nbytes=4):
    table = []  # list of swreg dictionaries

    for line in code:
        swreg_flds = swreg_get_fields(line)
        if swreg_flds is None:
            continue

        table.append(swreg_flds)

    # calculate address field
    table = calc_swreg_addr(table)

    regfile_name = top + "_swreg"

    if hwsw == "HW":
        write_hwheader(table, regfile_name, cpu_nbytes)
        write_hw(table, regfile_name, cpu_nbytes)

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
