#!/usr/bin/env python3
#
#    mkregs.py: build Verilog software accessible registers and software getters and setters
#

import sys, os
from math import ceil, log
from latex import write_table
from submodule_utils import eval_param_expression_from_config
import re

# Use a class for the entire module, as it may be imported multiple times, but must have instance variables (multiple cores/submodules have different registers)
class mkregs:
    def __init__(self):
        self.cpu_n_bytes = 4
        self.core_addr_w = None
        self.config = None

    @staticmethod
    def boffset(n, n_bytes):
        return 8*(n%n_bytes)

    @staticmethod
    def bfloor(n, log2base):
        base = int(2**log2base)
        if n%base == 0:
            return n
        return base*int(n/base)

    @staticmethod
    def verilog_max(a,b):
        return f"((({a}) > ({b})) ? ({a}) : ({b}))"

    def bceil(self, n, log2base):
        base = int(2**log2base)
        n = eval_param_expression_from_config(n, self.config,'max')
        #print(f"{n} of {type(n)} and {base}")
        if n%base == 0:
            return n
        else:
            return int(base*ceil(n/base))

    # Calculate numeric value of addr_w, replacing params by their max value
    def calc_addr_w(self, log2n_items, n_bytes):
            return int(ceil(eval_param_expression_from_config(log2n_items, self.config,'max')+log(n_bytes,2)))

    # Generate symbolic expression string to caluclate addr_w in verilog
    @staticmethod
    def calc_verilog_addr_w(log2n_items, n_bytes):
        if log2n_items == 0 :
            if n_bytes == 1 :
                return f"0"
            else :
                return f"$clog2({int(n_bytes)})"
        else :
            if n_bytes == 1 :
                return f"{log2n_items}"
            else :
                return f"{log2n_items}+$clog2({int(n_bytes)})"
            


    def gen_wr_reg(self, row, f):
        name = row['name']
        rst_val = row['rst_val']
        n_bits = row['n_bits']
        log2n_items = row['log2n_items']
        n_bytes = self.bceil(n_bits, 3)/8
        addr = row['addr']
        addr_w = self.calc_verilog_addr_w(log2n_items,n_bytes)
        auto = row['autologic']

        f.write(f"\n\n//NAME: {name}; TYPE: {row['type']}; WIDTH: {n_bits}; RST_VAL: {rst_val}; ADDR: {addr}; SPACE (bytes): {2**self.calc_addr_w(log2n_items,n_bytes)} (max); AUTO: {auto}\n\n")

        #compute wdata with only the needed bits
        if auto:
            f.write(f"`IOB_WIRE({name}_wdata, {self.verilog_max(n_bits,1)})\n")
            f.write(f"assign {name}_wdata = iob_wdata_i[{self.boffset(addr,self.cpu_n_bytes)}+:{self.verilog_max(n_bits,1)}];\n")

        #check if address in range
        f.write(f"`IOB_WIRE({name}_addressed, 1)\n")
        f.write(f"assign {name}_addressed = (waddr >= {addr}) && (waddr < ({addr}+(2**({addr_w}))));\n")

        if auto: #generate register
            f.write(f"`IOB_WIRE({name}_wen, 1)\n")
            f.write(f"assign {name}_wen = (iob_avalid_i) & ((|iob_wstrb_i) & {name}_addressed);\n")
            f.write(f"iob_reg_e #({n_bits},{rst_val}) {name}_datareg (clk_i, arst_i, cke_i, {name}_wen, {name}_wdata, {name}_o);\n")
        else: #compute wen
            f.write(f"assign {name}_wen_o = ({name}_addressed & iob_avalid_i)? |iob_wstrb_i: 1'b0;\n")
            
    def gen_rd_reg(self, row, f):
        name = row['name']
        rst_val = row['rst_val']
        n_bits = row['n_bits']
        log2n_items = row['log2n_items']
        n_bytes = self.bceil(n_bits, 3)/8
        addr = row['addr']
        addr_w = self.calc_verilog_addr_w(log2n_items,n_bytes)
        auto = row['autologic']

        f.write(f"\n\n//NAME: {name}; TYPE: {row['type']}; WIDTH: {n_bits}; RST_VAL: {rst_val}; ADDR: {addr}; SPACE (bytes): {2**self.calc_addr_w(log2n_items,n_bytes)} (max); AUTO: {auto}\n\n")

        if not auto: #output read enable
            f.write(f"`IOB_WIRE({name}_addressed, 1)\n")
            f.write(f"assign {name}_addressed = (iob_addr_i >= {addr}) && (iob_addr_i < ({addr}+(2**({addr_w}))));\n")
            f.write(f"assign {name}_ren_o = {name}_addressed & iob_avalid_i & (~|iob_wstrb_i);\n")

    # generate ports for swreg module
    def gen_port(self, table, f):
        for row in table:
            name = row['name']
            n_bits = row['n_bits']
            log2n_items = row['log2n_items']
            n_bytes = self.bceil(n_bits, 3)/8
            auto = row['autologic']
     
            
            if row['type'] == 'W':
                if auto:
                    f.write(f"\t`IOB_OUTPUT({name}_o, {self.verilog_max(n_bits,1)}),\n")
                else:
                    f.write(f"\t`IOB_OUTPUT({name}_wen_o, 1),\n")
            elif row['type'] == 'R':
                f.write(f"\t`IOB_INPUT({name}_i, {self.verilog_max(n_bits,1)}),\n")
                if not auto:
                    f.write(f"\t`IOB_OUTPUT({name}_ren_o, 1),\n")
                    f.write(f"\t`IOB_INPUT({name}_rvalid_i, 1),\n")
            if not auto:
                f.write(f"\t`IOB_INPUT({name}_ready_i, 1),\n")
                
        f.write(f"\t`IOB_OUTPUT(iob_ready_nxt_o, 1),\n")
        f.write(f"\t`IOB_OUTPUT(iob_rvalid_nxt_o, 1),\n")

    # generate wires to connect instance in top module
    def gen_inst_wire(self, table, f):
        for row in table:
            name = row['name']
            n_bits = row['n_bits']
            log2n_items = row['log2n_items']
            n_bytes = self.bceil(n_bits, 3)/8
            auto = row['autologic']
            rst_val = row['rst_val']

            if row['type'] == 'W':
                if auto:
                    f.write(f"`IOB_WIRE({name}, {self.verilog_max(n_bits,1)})\n")
                else:
                    f.write(f"`IOB_WIRE({name}_wen, 1)\n")
            elif row['type'] == 'R':
                f.write(f"`IOB_WIRE({name}, {self.verilog_max(n_bits,1)})\n")
                if not row['autologic']:
                    f.write(f"`IOB_WIRE({name}_rvalid, 1)\n")
                    f.write(f"`IOB_WIRE({name}_ren, 1)\n")
            if not auto:
                f.write(f"`IOB_WIRE({name}_ready, 1)\n")
        f.write(f"`IOB_WIRE(iob_ready_nxt, 1)\n")
        f.write(f"`IOB_WIRE(iob_rvalid_nxt, 1)\n")
        f.write("\n")

    # generate portmap for swreg instance in top module
    def gen_portmap(self, table, f):
        for row in table:
            name = row['name']
            n_bits = row['n_bits']
            log2n_items = row['log2n_items']
            n_bytes = self.bceil(n_bits, 3)/8
            auto = row['autologic']

            if row['type'] == 'W':
                if auto:
                    f.write(f"\t.{name}_o({name}),\n")
                else:
                    f.write(f"\t.{name}_wen_o({name}_wen),\n")
            else:
                f.write(f"\t.{name}_i({name}),\n")
                if not auto:
                    f.write(f"\t.{name}_ren_o({name}_ren),\n")
                    f.write(f"\t.{name}_rvalid_i({name}_rvalid),\n")
            if not auto:
                f.write(f"\t.{name}_ready_i({name}_ready),\n")

        f.write(f"\t.iob_ready_nxt_o(iob_ready_nxt),\n")
        f.write(f"\t.iob_rvalid_nxt_o(iob_rvalid_nxt),\n")


    def write_hwcode(self, table, out_dir, top):

        #
        # SWREG INSTANCE
        #

        os.makedirs(out_dir, exist_ok=True)
        f_inst = open(f"{out_dir}/{top}_swreg_inst.vh", "w")
        f_inst.write("//This file was generated by script mkregs.py\n\n")

        # connection wires
        self.gen_inst_wire(table, f_inst)

        f_inst.write(f'{top}_swreg_gen #(\n')
        f_inst.write(f'\t`include "{top}_inst_params.vh"\n')
        f_inst.write("\n) swreg_0 (\n")
        self.gen_portmap(table, f_inst)
        f_inst.write('\t`include "iob_s_portmap.vh"\n')
        f_inst.write('\t`include "iob_clkenrst_portmap.vh"')
        f_inst.write("\n);\n")

        #
        # SWREG MODULE
        #

        f_gen = open(f"{out_dir}/{top}_swreg_gen.v", "w")
        f_gen.write("//This file was generated by script mkregs.py\n\n")

        # time scale
        f_gen.write("`timescale 1ns / 1ps\n\n")

        # iob library
        f_gen.write(f'`include "iob_lib.vh"\n')
        
        # macros
        f_gen.write(f'`include "{top}_conf.vh"\n')
        f_gen.write(f'`include "{top}_swreg_def.vh"\n\n')

        # declaration
        f_gen.write(f'module {top}_swreg_gen\n')

        # parameters
        f_gen.write("#(\n")
        f_gen.write(f'`include "{top}_params.vh"\n')
        f_gen.write(")\n")
        f_gen.write("(\n")

        # ports
        self.gen_port(table, f_gen)
        f_gen.write('\t`include "iob_s_port.vh"\n')
        f_gen.write('\t`include "iob_clkenrst_port.vh"\n')
        f_gen.write(");\n\n")

        #write address
        f_gen.write("\n//write address\n")

        #extract address byte offset
        f_gen.write(f"`IOB_WIRE(byte_offset, ($clog2(DATA_W/8)+1))\n")
        f_gen.write(f"iob_ctls #(DATA_W/8, 1, 0) bo_inst (iob_wstrb_i, byte_offset);\n")

        #compute write address
        f_gen.write(f"`IOB_WIRE(waddr, ADDR_W)\n")
        f_gen.write(f"assign waddr = `IOB_WORD_ADDR(iob_addr_i) + byte_offset;\n")

        # insert write register logic
        for row in table:
            if row['type'] == 'W':
                self.gen_wr_reg(row, f_gen)


        # insert read register logic
        for row in table:
            if row['type'] == 'R':
                self.gen_rd_reg(row, f_gen)

        #
        # RESPONSE SWITCH
        #
        f_gen.write("\n\n//RESPONSE SWITCH\n")

        # use variables to compute response
        f_gen.write(f"\n`IOB_VAR(rdata_int, {8*self.cpu_n_bytes})\n")
        f_gen.write(f"`IOB_VAR(rvalid_int, 1)\n")
        f_gen.write(f"`IOB_VAR(wready_int, 1)\n")
        f_gen.write(f"`IOB_VAR(rready_int, 1)\n\n")
        
        #ready output
        f_gen.write("//ready output\n")
        f_gen.write("`IOB_VAR(ready_nxt, 1)\n")
        f_gen.write("iob_reg #(1,1) ready_reg_inst (clk_i, arst_i, cke_i, ready_nxt, iob_ready_o);\n\n")
        
        #rvalid output
        f_gen.write("//rvalid output\n")
        f_gen.write("`IOB_VAR(rvalid_nxt, 1)\n")
        f_gen.write("iob_reg #(1,0) rvalid_reg_inst (clk_i, arst_i, cke_i, rvalid_nxt, iob_rvalid_o);\n\n")
        
        #rdata output
        f_gen.write("//rdata output\n")
        f_gen.write(f"iob_reg #({8*self.cpu_n_bytes},0) rdata_reg_inst (clk_i, arst_i, cke_i, rdata_int, iob_rdata_o);\n\n")
        
        f_gen.write("`IOB_WIRE(pc, 1)\n")
        f_gen.write("`IOB_VAR(pc_nxt, 1)\n")
        f_gen.write("iob_reg #(1,0) pc_reg (clk_i, arst_i, cke_i, pc_nxt, pc);\n\n")

        f_gen.write("`IOB_COMB begin\n")

        f_gen.write(f"\trdata_int = {8*self.cpu_n_bytes}'d0;\n")
        f_gen.write(f"\trready_int = 1'b1;\n")
        f_gen.write(f"\trvalid_int = 1'b1;\n")
        f_gen.write(f"\twready_int = 1'b1;\n\n")
        

        #read register response
        for row in table:
            name = row['name']
            addr = row['addr']
            n_bits = row['n_bits']
            log2n_items = row['log2n_items']
            n_bytes = int(self.bceil(n_bits, 3)/8)
            addr_last = int(addr + ((2**eval_param_expression_from_config(log2n_items, self.config,'max'))-1)*n_bytes)
            addr_w = self.calc_addr_w(log2n_items,n_bytes)
            addr_w_base = max(log(self.cpu_n_bytes,2), addr_w)
            auto = row['autologic']

            if row['type'] == 'R':
                if self.bfloor(addr, addr_w_base) == self.bfloor(addr_last, addr_w_base) :
                    f_gen.write(f"\tif(`IOB_WORD_ADDR(iob_addr_i) == {self.bfloor(addr, addr_w_base)}) ")
                else :
                    f_gen.write(f"\tif((`IOB_WORD_ADDR(iob_addr_i) >= {self.bfloor(addr, addr_w_base)}) && (`IOB_WORD_ADDR(iob_addr_i) <= {self.bfloor(addr_last, addr_w_base)})) ")
                f_gen.write(f"begin\n")
                f_gen.write(f"\t\trdata_int[{self.boffset(addr, self.cpu_n_bytes)}+:{8*n_bytes}] = {name}_i|{8*n_bytes}'d0;\n")
                if not auto:
                    f_gen.write(f"\t\trready_int = {name}_ready_i;\n")
                    f_gen.write(f"\t\trvalid_int = {name}_rvalid_i;\n")
                f_gen.write(f"\tend\n\n")


        #write register response
        for row in table:
            name = row['name']
            addr = row['addr']
            n_bits = row['n_bits']
            log2n_items = row['log2n_items']
            n_bytes = int(self.bceil(n_bits, 3)/8)
            addr_w = self.calc_addr_w(log2n_items,n_bytes)
            auto = row['autologic']

            if row['type'] == 'W':
                if not auto:
                    # get wready
                    f_gen.write(f"\tif((waddr >= {addr}) && (waddr < {addr + 2**addr_w}))\n")
                    f_gen.write(f"\t\twready_int = {name}_ready_i;\n\n")
        
        f_gen.write("\tready_nxt = (|iob_wstrb_i)? wready_int: rready_int;\n")
        f_gen.write("\trvalid_nxt = iob_rvalid_o;\n")
        f_gen.write("\tpc_nxt = pc + 1'b1;\n\n")
        f_gen.write("\tcase(pc)\n")
        f_gen.write("\t\t0: begin\n")
        f_gen.write("\t\t\trvalid_nxt = 1'b0;\n")
        f_gen.write("\t\t\tif(!iob_avalid_i)\n")
        f_gen.write("\t\t\t\tpc_nxt=pc;\n")
        f_gen.write("\t\tend\n")
        f_gen.write("\t\tdefault: begin\n")
        f_gen.write("\t\t\trvalid_nxt =  (|iob_wstrb_i)? 1'b0: rvalid_int;\n")
        f_gen.write("\t\t\tif((|iob_wstrb_i)? !iob_ready_o: !rvalid_int)\n")
        f_gen.write("\t\t\t\tpc_nxt = pc;\n")
        f_gen.write("\t\tend\n")
        f_gen.write("\tendcase\n")

        f_gen.write("end //IOB_COMB\n\n")

        #ready_nxt output
        f_gen.write("//ready_nxt output\n")
        f_gen.write("assign iob_ready_nxt_o = ready_nxt;\n")
     
        #rvalid_nxt output
        f_gen.write("//rvalid_nxt output\n")
        f_gen.write("assign iob_rvalid_nxt_o = rvalid_nxt;\n\n")

        f_gen.write("endmodule\n")
        f_gen.close()
        f_inst.close()

    # Generate *_swreg_lparam.vh file. Macros from this file contain the default values of the registers. These should not be used inside the instance of the core/system.
    def write_lparam_header(self, table, out_dir, top):
        os.makedirs(out_dir, exist_ok=True)
        f_def = open(f"{out_dir}/{top}_swreg_lparam.vh", "w")
        f_def.write("//This file was generated by script mkregs.py\n\n")
        f_def.write("//used address space width\n")
        addr_w_prefix = f"{top}_swreg".upper()
        f_def.write(f"localparam {addr_w_prefix}_ADDR_W = {self.core_addr_w};\n\n")
        f_def.write("//These macros only contain default values for the registers\n")
        f_def.write("//address macros\n")
        macro_prefix = f"{top}_".upper()
        f_def.write("//addresses\n")
        for row in table:
            name = row['name']
            n_bits = row['n_bits']
            n_bytes = self.bceil(n_bits, 3)/8
            log2n_items = row['log2n_items']
            addr_w = int(ceil(eval_param_expression_from_config(log2n_items, self.config,'val')+log(n_bytes,2)))
            f_def.write(f"localparam {macro_prefix}{name}_ADDR = {row['addr']};\n")
            if eval_param_expression_from_config(log2n_items, self.config,'val')>0:
                f_def.write(f"localparam {macro_prefix}{name}_ADDR_W = {addr_w};\n")
            f_def.write(f"localparam {macro_prefix}{name}_W = {eval_param_expression_from_config(n_bits, self.config,'val')};\n\n")
        f_def.close()

    # Generate *_swreg_def.vh file. Macros from this file should only be used inside the instance of the core/system since they may contain parameters which are only known by the instance.
    def write_hwheader(self, table, out_dir, top):
        os.makedirs(out_dir, exist_ok=True)
        f_def = open(f"{out_dir}/{top}_swreg_def.vh", "w")
        f_def.write("//This file was generated by script mkregs.py\n\n")
        f_def.write("//used address space width\n")
        addr_w_prefix = f"{top}_swreg".upper()
        f_def.write(f"`define {addr_w_prefix}_ADDR_W {self.core_addr_w}\n\n")
        f_def.write("//These macros may be dependent on instance parameters\n")
        f_def.write("//address macros\n")
        macro_prefix = f"{top}_".upper()
        f_def.write("//addresses\n")
        for row in table:
            name = row['name']
            n_bits = row['n_bits']
            n_bytes = self.bceil(n_bits, 3)/8
            log2n_items = row['log2n_items']
            f_def.write(f"`define {macro_prefix}{name}_ADDR {row['addr']}\n")
            if eval_param_expression_from_config(log2n_items, self.config,'max')>0:
                f_def.write(f"`define {macro_prefix}{name}_ADDR_W {self.verilog_max(self.calc_verilog_addr_w(log2n_items,n_bytes),1)}\n")
            f_def.write(f"`define {macro_prefix}{name}_W {self.verilog_max(n_bits,1)}\n\n")
        f_def.close()


    # Get C type from swreg n_bytes
    # uses unsigned int types from C stdint library
    @staticmethod
    def swreg_type(name, n_bytes):
        type_dict = {1: "uint8_t", 2: "uint16_t", 4: "uint32_t", 8: "uint64_t"}
        try:
            type_try = type_dict[n_bytes]
        except:
            print(f"Error: register {name} has invalid number of bytes {n_bytes}.")
        return type_try


    def write_swheader(self, table, out_dir, top):
        os.makedirs(out_dir, exist_ok=True)
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
            n_bytes = int(self.bceil(n_bits, 3)/8)
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
            log2n_items = row['log2n_items']
            n_bytes = self.bceil(n_bits, 3)/8
            addr_w = self.calc_addr_w(log2n_items, n_bytes)
            if row["type"] == "W":
                sw_type = self.swreg_type(name, n_bytes)
                addr_arg = ""
                if addr_w / n_bytes > 1:
                    addr_arg = ", int addr"
                fswhdr.write(f"void {core_prefix}SET_{name}({sw_type} value{addr_arg});\n")
            if row["type"] == "R":
                sw_type = self.swreg_type(name, n_bytes  )
                addr_arg = ""
                if addr_w / n_bytes > 1:
                    addr_arg = "int addr"
                fswhdr.write(f"{sw_type} {core_prefix}GET_{name}({addr_arg});\n")

        fswhdr.write(f"\n#endif // H_{core_prefix}_SWREG_H\n")

        fswhdr.close()


    def write_swcode(self, table, out_dir, top):
        os.makedirs(out_dir, exist_ok=True)
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
            log2n_items = row['log2n_items']
            n_bytes = self.bceil(n_bits, 3)/8
            addr_w = self.calc_addr_w(log2n_items, n_bytes)
            if row["type"] == "W":
                sw_type = self.swreg_type(name, n_bytes)
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
                sw_type = self.swreg_type(name, n_bytes)
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
    @staticmethod
    def check_alignment(addr, addr_w):
        if addr % (2**addr_w) != 0:
            sys.exit(f"Error: address {addr} with span {2**addr_w} is not aligned")

    # check if address overlaps with previous
    @staticmethod
    def check_overlap(addr, addr_type, read_addr, write_addr):
        if addr_type == "R" and addr < read_addr:
            sys.exit(f"Error: read address {addr} overlaps with previous addresses")
        elif addr_type == "W" and addr < write_addr:
            sys.exit(f"Error: write address {addr} overlaps with previous addresses")

    # compute address
    def compute_addr(self, table, no_overlap):
        read_addr = 0
        write_addr = 0

        tmp = []

        for row in table:
            addr = row['addr']
            addr_type = row['type']
            n_bits = row['n_bits']
            log2n_items = row['log2n_items']
            n_bytes = self.bceil(n_bits, 3)/8
            addr_w = self.calc_addr_w(log2n_items,n_bytes)
            if addr >= 0: #manual address
                self.check_alignment(addr, addr_w)
                self.check_overlap(addr, addr_type, read_addr, write_addr)
                addr_tmp = addr
            elif addr_type == 'R': #auto address
                read_addr = self.bceil(read_addr, addr_w)
                addr_tmp = read_addr
            elif addr_type == 'W':
                write_addr = self.bceil(write_addr, addr_w)
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
        self.core_addr_w = int(ceil(log(max(read_addr, write_addr), 2)))

        return table

    # Generate swreg.tex file with list TeX tables of regs
    @staticmethod
    def generate_swreg_tex(regs, out_dir):
        os.makedirs(out_dir, exist_ok=True)
        swreg_file = open(f"{out_dir}/swreg.tex", "w")

        swreg_file.write(\
    '''
    The software accessible registers of the core are described in the following
    tables. The tables give information on the name, read/write capability, address, width in bits, and a textual description.
    '''
        )

        for table in regs:
            swreg_file.write(\
    '''
    \\begin{table}[H]
      \centering
      \\begin{tabularx}{\\textwidth}{|l|c|c|c|c|X|}
        
        \hline
        \\rowcolor{iob-green}
        {\\bf Name} & {\\bf R/W} & {\\bf Addr} & {\\bf Width} & {\\bf Default} & {\\bf Description} \\\\ \hline

        \input '''+table['name']+'''_swreg_tab
     
      \end{tabularx}
      \caption{'''+table['descr'].replace('_','\_')+'''}
      \label{'''+table['name']+'''_swreg_tab:is}
    \end{table}
    '''
            )

        swreg_file.write("\clearpage")
        swreg_file.close()

    # Generate TeX tables of registers
    # regs: list of tables containing registers, as defined in <corename>_setup.py
    # regs_with_addr: list of all registers, where 'addr' field has already been computed
    # out_dir: output directory
    @classmethod
    def generate_regs_tex(cls, regs, regs_with_addr, out_dir):
        os.makedirs(out_dir, exist_ok=True)
        # Create swreg.tex file
        cls.generate_swreg_tex(regs,out_dir)

        for table in regs:
            tex_table = []
            for reg in table['regs']:
                tex_table.append([reg['name'].replace('_','\_'), reg['type'],
                                 # Find address of matching register in regs_with_addr list
                                 next(register['addr'] for register in regs_with_addr if register['name'] == reg['name']),
                                 str(reg['n_bits']).replace('_','\_'), str(reg['rst_val']).replace('_','\_'), reg['descr'].replace('_','\_')])

            write_table(f"{out_dir}/{table['name']}_swreg",tex_table)
