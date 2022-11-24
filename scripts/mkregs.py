#!/usr/bin/env python3
#
#    mkregs.py: build Verilog software accessible registers and software getters and setters
#

import sys
from math import ceil, log
from latex import write_table

cpu_n_bytes = 4
core_addr_w = None
config = None

def boffset(n, n_bytes):
    return 8*(n%n_bytes)

def bfloor(n, log2base):
    base = int(2**log2base)
    if n%base == 0:
        return n
    return base*int(n/base)

def bceil(n, log2base):
    base = int(2**log2base)
    n = compute_n_bits_value(n, config)
    #print(f"{n} of {type(n)} and {base}")
    if n%base == 0:
        return n
    else:
        return int(base*ceil(n/base))

def gen_wr_reg(row, f):
    name = row['name']
    rst_val = row['rst_val']
    n_bits = row['n_bits']
    n_items = row['n_items']
    n_bytes = bceil(n_bits, 3)/8
    addr = row['addr']
    addr_w = int(ceil(log(n_items*n_bytes,2)))
    auto = row['autologic']

    f.write(f"\n\n//NAME: {name}; TYPE: {row['type']}; WIDTH: {n_bits}; RST_VAL: {rst_val}; ADDR: {addr}; SPACE (bytes): {2**addr_w}; AUTO: {auto}\n\n")

    #compute wdata with only the needed bits
    f.write(f"`IOB_WIRE({name}_wdata, {n_bits})\n")
    f.write(f"assign {name}_wdata = iob_wdata_i[{boffset(addr,cpu_n_bytes)}+:{n_bits}];\n")

    #check if address in range
    f.write(f"`IOB_WIRE({name}_addressed, )\n")
    f.write(f"assign {name}_addressed = (waddr >= {addr} && waddr < {addr+2**addr_w});\n")

    #declare wen signal
    f.write(f"`IOB_WIRE({name}_wen, 1)\n")

    #generate register logic
    if auto: #generate register and ready signal
        f.write(f"`IOB_WIRE({name}_ready_i, 1)\n")
        f.write(f"assign {name}_ready_i = |iob_wstrb_i;\n")
        f.write(f"iob_reg #({n_bits},{rst_val}) {name}_datareg (clk_i, rst_i, 1'b0, {name}_wen, {name}_wdata, {name}_o);\n")
    else: #output wdata and wen; ready signal has been declared as a port
        f.write(f"assign {name}_o = {name}_wdata;\n")
        f.write(f"assign {name}_wen_o = {name}_wen;\n")

    #compute write enable
    f.write(f"assign {name}_wen = {name}_ready_i && iob_valid_i && iob_wstrb_i && {name}_addressed;\n")

    #compute address for register range
    if n_items > 1:
        f.write(f"assign {name}_addr_o = iob_addr_i[{addr_w}-1:0];\n")

def gen_rd_reg(row, f):
    name = row['name']
    rst_val = row['rst_val']
    n_bits = row['n_bits']
    n_items = row['n_items']
    n_bytes = bceil(n_bits, 3)/8
    addr = row['addr']
    addr_last = int(addr + (n_items-1)*n_bytes)
    addr_w = int(ceil(log(n_items*n_bytes,2)))
    auto = row['autologic']
    addr_base = max(log(cpu_n_bytes,2), addr_w)

    f.write(f"\n\n//NAME: {name}; TYPE: {row['type']}; WIDTH: {n_bits}; RST_VAL: {rst_val}; ADDR: {addr}; SPACE (bytes): {2**addr_w}; AUTO: {auto}\n\n")

    #declare ren signal
    f.write(f"`IOB_WIRE({name}_ren, 1)\n")

    #generate register logic
    if auto:#generate register, ready, rvalid signal
        #ready
        f.write(f"`IOB_WIRE({name}_ready_i, 1)\n")
        f.write(f"assign {name}_ready_i = !iob_wstrb_i;\n")
        #rvalid
        f.write(f"`IOB_WIRE({name}_rvalid_i, 1)\n")
        f.write(f"iob_reg #(1,0) {name}_rvalid (clk_i, rst_i, 1'b0, 1'b1, {name}_ren, {name}_rvalid_i);\n")
        #register
        f.write(f"`IOB_WIRE({name}_r, {n_bits})\n")
        f.write(f"iob_reg #({n_bits},{rst_val}) {name}_datareg (clk_i, rst_i, 1'b0, {name}_ren, {name}_i, {name}_r);\n")
        f.write(f"assign {name}_int_o = {name}_r;\n")
    else:
        f.write(f"assign {name}_ren_o = {name}_ren;\n")

    #check if address in range
    f.write(f"`IOB_WIRE({name}_addressed, )\n")
    f.write(f"assign {name}_addressed = `IOB_WORD_ADDR(iob_addr_i) >= {bfloor(addr, addr_base)} && `IOB_WORD_ADDR(iob_addr_i) <= {bfloor(addr_last, addr_base)};\n")

    #compute the read enable signal
    f.write(f"assign {name}_ren = {name}_ready_i && iob_valid_i && !iob_wstrb_i && {name}_addressed;\n")
    if n_items > 1:
        f.write(f"assign {name}_addr_o = iob_addr_i[{addr_w}-1:0];\n")

# generate ports for swreg module
def gen_port(table, f):
    for row in table:
        name = row['name']
        n_bits = row['n_bits']
        n_items = row['n_items']
        n_bytes = bceil(n_bits, 3)/8
        addr_w = int(ceil(log(row['n_items']*n_bytes,2)))
        auto = row['autologic']
 
        
        if row['type'] == 'W':
            f.write(f"\t`IOB_OUTPUT({name}_o, {n_bits}),\n")
            if not auto:
                f.write(f"\t`IOB_OUTPUT({name}_wen_o, 1),\n")
        else:
            f.write(f"\t`IOB_INPUT({name}_i, {n_bits}),\n")
            if not auto:
                f.write(f"\t`IOB_OUTPUT({name}_ren_o, 1),\n")
                f.write(f"\t`IOB_INPUT({name}_rvalid_i, 1),\n")
            else:
                f.write(f"\t`IOB_OUTPUT({name}_int_o, {n_bits}),\n")
        if not auto:
            f.write(f"\t`IOB_INPUT({name}_ready_i, 1),\n")
        if n_items > 1:
            f.write(f"\t`IOB_OUTPUT({name}_addr_o, {addr_w}),\n")

# generate wires to connect instance in top module
def gen_inst_wire(table, f):
    for row in table:
        name = row['name']
        n_bits = row['n_bits']
        n_items = row['n_items']
        n_bytes = bceil(n_bits, 3)/8
        addr_w = int(ceil(log(row['n_items']*n_bytes,2)))
        auto = row['autologic']


        if row['type'] == 'W':
            f.write(f"`IOB_WIRE({name}, {n_bits})\n")
            if not auto:
                f.write(f"`IOB_WIRE({name}_wen, 1)\n")
        else:
            f.write(f"`IOB_WIRE({name}, {n_bits})\n")
            if not row['autologic']:
                f.write(f"`IOB_WIRE({name}_rvalid, 1)\n")
                f.write(f"`IOB_WIRE({name}_ren, 1)\n")
            else:
                f.write(f"`IOB_WIRE({name}_int, {n_bits})\n")
        if not auto:
            f.write(f"`IOB_WIRE({name}_ready, 1)\n")
        if n_items > 1:
            f.write(f"`IOB_WIRE({name}_addr, {addr_w})\n")
    f.write("\n")

# generate portmap for swreg instance in top module
def gen_portmap(table, f):
    for row in table:
        name = row['name']
        n_bits = row['n_bits']
        n_items = row['n_items']
        n_bytes = bceil(n_bits, 3)/8
        addr_w = int(ceil(log(row['n_items']*n_bytes,2)))
        auto = row['autologic']

        if row['type'] == 'W':
            f.write(f"\t.{name}_o({name}),\n")
            if not auto:
                f.write(f"\t.{name}_wen_o({name}_wen),\n")
        else:
            f.write(f"\t.{name}_i({name}),\n")
            if not auto:
                f.write(f"\t.{name}_rvalid_i({name}_rvalid),\n")
                f.write(f"\t.{name}_ren_o({name}_ren),\n")
            else:
                f.write(f"\t.{name}_int_o({name}_int),\n")
        if not auto:
            f.write(f"\t.{name}_ready_i({name}_ready),\n")
        if n_items > 1:
            f.write(f"\t.{name}_addr_o({name}_addr),\n")


def write_hwcode(table, out_dir, top):

    #
    # SWREG INSTANCE
    #

    f_inst = open(f"{out_dir}/{top}_swreg_inst.vh", "w")
    f_inst.write("//This file was generated by script mkregs.py\n\n")

    # connection wires
    gen_inst_wire(table, f_inst)

    f_inst.write("swreg #(\n")
    f_inst.write(f'\t`include "{top}_inst_params.vh"\n')
    f_inst.write("\n) swreg_inst (\n")
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

    # macros
    f_gen.write(f'`include "{top}_conf.vh"\n')
    f_gen.write(f'`include "{top}_swreg_def.vh"\n')

    # declaration
    f_gen.write("module swreg\n")

    # parameters
    f_gen.write("#(\n")
    f_gen.write(f'`include "{top}_params.vh"\n')
    f_gen.write(")\n")
    f_gen.write("(\n")

    # ports
    gen_port(table, f_gen)
    f_gen.write('\t`include "iob_s_port.vh"\n')
    f_gen.write('\t`include "iob_clkrst_port.vh"\n')
    f_gen.write(");\n\n")

    #write address
    f_gen.write("\n//write address\n")

    #extract address byte offset
    f_gen.write(f"`IOB_WIRE(byte_offset, $clog2(DATA_W/8))\n")
    f_gen.write(f"iob_wstrb2byte_offset #(DATA_W/8) bo_inst (iob_wstrb_i, byte_offset);\n")

    #compute write address
    f_gen.write(f"`IOB_WIRE(waddr, ADDR_W)\n")
    f_gen.write(f"assign waddr = `IOB_WORD_ADDR(iob_addr_i) + byte_offset;\n")


    
    # insert register logic
    has_read_regs = 0
    for row in table:
        if row['type'] == 'W':
            # write register
            gen_wr_reg(row, f_gen)
        else:
            # generate address register only once
            if not has_read_regs:
                has_read_regs = 1
                f_gen.write("//address register\n")
                f_gen.write(f"`IOB_WIRE(raddr, {core_addr_w})\n")
                f_gen.write(f"iob_reg #({core_addr_w}, 0) raddr_reg (clk_i, rst_i, 1'b0, iob_valid_i, iob_addr_i, raddr);\n\n")
            # read register
            gen_rd_reg(row, f_gen)

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
        n_bits = row['n_bits']
        n_items = row['n_items']
        n_bytes = bceil(n_bits, 3)/8
        addr_last = int(addr + (n_items-1)*n_bytes)
        addr_w = int(ceil(log(n_items*n_bytes,2)))
        addr_type = row['type']
        auto = row['autologic']
        addr_base = max(log(cpu_n_bytes,2), addr_w)

        if row['type'] == 'R':
            f_gen.write(f"\tif(`IOB_WORD_ADDR(raddr) >= {bfloor(addr, addr_base)} && `IOB_WORD_ADDR(raddr) <= {bfloor(addr_last, addr_base)}) begin\n")
            # rdata
            if auto:
                f_gen.write(f"\t\trdata_int = rdata_int | (({name}_r|{8*cpu_n_bytes}'d0) << {boffset(addr, cpu_n_bytes)});\n")
            else:
                f_gen.write(f"\t\trdata_int = rdata_int | (({name}_i|{8*cpu_n_bytes}'d0) << {boffset(addr, cpu_n_bytes)});\n")
            # rvalid
            f_gen.write(f"\t\trvalid_int = rvalid_int | {name}_rvalid_i;\n\tend\n")
            # rready
            f_gen.write(f"\tif(`IOB_WORD_ADDR(iob_addr_i) >= {bfloor(addr, addr_base)} && `IOB_WORD_ADDR(iob_addr_i) <= {bfloor(addr_last, addr_base)})\n")
            f_gen.write(f"\t\trready_int = rready_int | {name}_ready_i;\n")
        else: #row['type'] == 'W'
            # get wready
            f_gen.write(f"\tif(waddr >= {addr} && waddr < {addr + 2**addr_w})\n")
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
        n_bits = row['n_bits']
        f_def.write(f"`define {macro_prefix}{name}_ADDR {row['addr']}\n")
        if type(n_bits)==int:
            f_def.write(f"`define {macro_prefix}{name}_W {n_bits}\n\n")
        elif n_bits != f"{name}_W":
            f_def.write(f"`define {macro_prefix}{name}_W `{macro_prefix}{n_bits}\n\n")
        else:
            f_def.write("\n")
    f_def.close()


# Get C type from swreg n_bytes
# uses unsigned int types from C stdint library
def swreg_type(name, n_bytes):
    type_dict = {1: "uint8_t", 2: "uint16_t", 4: "uint32_t", 8: "uint64_t"}
    try:
        type_try = type_dict[n_bytes]
    except:
        print(f"Error: register {name} has invalid number of bytes {n_bytes}.")
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
        if row["type"] == "W":
            fswhdr.write(f"#define {core_prefix}{name} {row['addr']}\n")
        if row["type"] == "R":
            fswhdr.write(f"#define {core_prefix}{name} {row['addr']}\n")

    fswhdr.write("\n//Data widths (bit)\n")
    for row in table:
        name = row['name']
        n_bits = row['n_bits']
        n_bytes = bceil(n_bits, 3)/8
        if row["type"] == "W":
            fswhdr.write(f"#define {core_prefix}{name}_W {n_bytes*8}\n")
        if row["type"] == "R":
            fswhdr.write(f"#define {core_prefix}{name}_W {n_bytes*8}\n")

    fswhdr.write("\n// Base Address\n")
    fswhdr.write(f"void {core_prefix}INIT_BASEADDR(uint32_t addr);\n")

    fswhdr.write("\n// Core Setters and Getters\n")
    for row in table:
        name = row['name']
        n_bits = row['n_bits']
        n_items = row['n_items']
        n_bytes = bceil(n_bits, 3)/8
        addr_w = int(ceil(log(n_items*n_bytes,2)))
        if row["type"] == "W":
            sw_type = swreg_type(name, n_bytes)
            addr_arg = ""
            if addr_w / n_bytes > 1:
                addr_arg = ", int addr"
            fswhdr.write(f"void {core_prefix}SET_{name}({sw_type} value{addr_arg});\n")
        if row["type"] == "R":
            sw_type = swreg_type(name, n_bytes  )
            addr_arg = ""
            if addr_w / n_bytes > 1:
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
        n_bits = row['n_bits']
        n_items = row['n_items']
        n_bytes = bceil(n_bits, 3)/8
        addr_w = int(ceil(log(n_items*n_bytes,2)))
        if row["type"] == "W":
            sw_type = swreg_type(name, n_bytes)
            addr_arg = ""
            addr_arg = ""
            addr_shift = ""
            if addr_w / n_bytes > 1:
                addr_arg = ", int addr"
                addr_shift = f" + (addr << {int(log(n_bytes, 2))})"
            fsw.write(f"void {core_prefix}SET_{name}({sw_type} value{addr_arg}) {{\n")
            fsw.write(f"\t(*( (volatile {sw_type} *) ( (base) + ({core_prefix}{name}){addr_shift}) ) = (value));\n")
            fsw.write("}\n\n")
        if row["type"] == "R":
            sw_type = swreg_type(name, n_bytes)
            addr_arg = ""
            addr_shift = ""
            if addr_w / n_bytes > 1:
                addr_arg = "int addr"
                addr_shift = f" + (addr << {int(log(n_bytes, 2))})"
            fsw.write(f"{sw_type} {core_prefix}GET_{name}({addr_arg}) {{\n")
            fsw.write(f"\treturn (*( (volatile {sw_type} *) ( (base) + ({core_prefix}{name}){addr_shift}) ));\n")
            fsw.write("}\n\n")
    fsw.close()

# check if address is aligned 
def check_alignment(addr, addr_w):
    if addr % (2**addr_w) != 0:
        sys.exit(f"Error: address {addr} with span {2**addr_w} is not aligned")

# check if address overlaps with previous
def check_overlap(addr, addr_type, read_addr, write_addr):
    if addr_type == "R" and addr < read_addr:
        sys.exit(f"Error: read address {addr} overlaps with previous addresses")
    elif addr_type == "W" and addr < write_addr:
        sys.exit(f"Error: write address {addr} overlaps with previous addresses")

def compute_n_bits_value(n_bits, config):
        if type(n_bits)==int:
            return n_bits
        else:
            for param in config:
                if param['name']==n_bits:
                    try:
                        return int(param['val'])
                    except:
                        return int(param['max'])
        sys.exit(f"Error: register 'n_bits':'{n_bits}' is not well defined.")

# compute address
def compute_addr(table, no_overlap):
    read_addr = 0
    write_addr = 0

    tmp = []

    for row in table:
        addr = row['addr']
        addr_type = row['type']
        n_bits = row['n_bits']
        n_items = row['n_items']
        n_bytes = bceil(n_bits, 3)/8
        addr_w = int(ceil(log(n_items*n_bytes,2)))
        if addr >= 0: #manual address
            check_alignment(addr, addr_w)
            check_overlap(addr, addr_type, read_addr, write_addr)
        elif addr_type == 'R': #auto address
            read_addr = bceil(read_addr, addr_w)
            addr_tmp = read_addr
        elif addr_type == 'W':
            write_addr = bceil(write_addr, addr_w)
            addr_tmp = write_addr
        if no_overlap:
            addr_tmp = max(read_addr, write_addr)

        #save address temporarily in list
        tmp.append(addr_tmp);

        #update addresses
        addr_tmp+= 2**addr_w
        if addr_type == 'R':
            read_addr = addr_tmp
        elif addr_type == 'W':
            write_addr = addr_tmp
        if no_overlap:
            read_addr = addr_tmp
            write_addr = addr_tmp

    #update reg addresses
    for i in range(len(tmp)):
        table[i]['addr']=tmp[i]

            
    #update core address space size
    global core_addr_w
    core_addr_w = int(ceil(log(max(read_addr, write_addr), 2)))

    return table


# Generate TeX tables of registers
# regs: list of tables containing registers, as defined in <corename>_setup.py
# regs_with_addr: list of all registers, where 'addr' field has already been computed
def generate_regs_tex(regs, regs_with_addr, out_dir):
    for table in regs:
        tex_table = []
        for reg in table['regs']:
            tex_table.append([reg['name'].replace('_','\_'), reg['type'],
                             # Find address of matching register in regs_with_addr list
                             next(register['addr'] for register in regs_with_addr if register['name'] == reg['name']),
                             reg['n_bits'], reg['rst_val'], reg['descr']])

        write_table(f"{out_dir}/{table['name']}_swreg",tex_table)
