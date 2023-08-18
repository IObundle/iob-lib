#!/usr/bin/env python3

# this script generates interfaces for Verilog modules and testbenches to add a
# new standard interface, add the name to the interface_names list, and an
# interface dictionary as below run this script with the -h option for help

import sys
import argparse
import re

interface_names = [
    "iob",
    "clk_en_rst",
    "clk_rst",
    "rom_sp",
    "rom_dp",
    "rom_tdp",
    "ram_sp_be",
    "ram_sp_se",
    "ram_sp",
    "ram_2p_be",
    "ram_2p_tiled",
    "ram_2p",
    "ram_t2p",
    "ram_dp_be_xil",
    "ram_dp_be",
    "ram_dp",
    "ram_tdp_be",
    "ram_tdp",
    "axil_read",
    "axil_write",
    "axil",
    "axi_read",
    "axi_write",
    "axi",
    "ahb",
    "apb",
    "axis",
]
    
interface_types = [
    "m_port",
    "s_port",
    "m_portmap",
    "s_portmap",
    "m_m_portmap",
    "s_s_portmap",
    "wire",
    "m_tb_wire",
    "s_tb_wire",
    ]
    


#interfaces 

iob = [
    {
        "type": "output",
        "n_bits": "1",
        "name": "iob_avalid",
        "default": "0",
        "descr": "Request valid.",
    },
    {
        "type": "output",
        "n_bits": "ADDR_W",
        "name": "iob_addr",
        "default": "0",
        "descr": "Address.",
    },
    {
        "type": "output",
        "n_bits": "DATA_W",
        "name": "iob_wdata",
        "default": "0",
        "descr": "Write data.",
    },
    {
        "type": "output",
        "n_bits": "(DATA_W/8)",
        "name": "iob_wstrb",
        "default": "0",
        "descr": "Write strobe.",
    },
    {
        "type": "input",
        "n_bits": "1",
        "name": "iob_rvalid",
        "default": "0",
        "descr": "Read data valid.",
    },
    {
        "type": "input",
        "n_bits": "DATA_W",
        "name": "iob_rdata",
        "default": "0",
        "descr": "Read data.",
    },
    {
        "type": "input",
        "n_bits": "1",
        "name": "iob_ready",
        "default": "0",
        "descr": "Interface ready.",
    },
]

clk_rst = [
    {
        "type": "output",
        "n_bits": "1",
        "name": "clk",
        "default": "0",
        "descr": "clock signal",
    },
    {
        "type": "output",
        "n_bits": "1",
        "name": "arst",
        "default": "0",
        "descr": "asynchronous reset",
    },
]

clk_en_rst = [
    {
        "type": "output",
        "n_bits": "1",
        "name": "clk",
        "default": "0",
        "descr": "clock signal",
    },
    {
        "type": "output",
        "n_bits": "1",
        "name": "cke",
        "default": "0",
        "descr": "clock enable",
    },
    {
        "type": "output",
        "n_bits": "1",
        "name": "arst",
        "default": "0",
        "descr": "asynchronous reset",
    },
]

rom = [
    {
        "sp": 1,
        "tdp": 0,
        "dp": 1,
        "type": "input",
        "n_bits": "1",
        "name": "clk",
        "default": "0",
        "descr": "clock",
    },
    {
        "sp": 1,
        "tdp": 0,
        "dp": 0,
        "type": "input",
        "n_bits": "1",
        "name": "r_en",
        "default": "0",
        "descr": "read enable",
    },
    {
        "sp": 1,
        "tdp": 0,
        "dp": 0,
        "type": "input",
        "n_bits": "ADDR_W",
        "name": "addr",
        "default": "0",
        "descr": "address",
    },
    {
        "sp": 1,
        "tdp": 0,
        "dp": 0,
        "type": "output",
        "n_bits": "DATA_W",
        "name": "r_data",
        "default": "0",
        "descr": "read data",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 0,
        "type": "input",
        "n_bits": "1",
        "name": "clk_a",
        "default": "0",
        "descr": "clock port A",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 0,
        "type": "input",
        "n_bits": "1",
        "name": "clk_b",
        "default": "0",
        "descr": "clock port B",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "type": "input",
        "n_bits": "1",
        "name": "r_en_a",
        "default": "0",
        "descr": "read enable port A",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "type": "input",
        "n_bits": "ADDR_W",
        "name": "addr_a",
        "default": "0",
        "descr": "address port A",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "type": "output",
        "n_bits": "DATA_W",
        "name": "r_data_a",
        "default": "0",
        "descr": "read data port A",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "type": "input",
        "n_bits": "1",
        "name": "r_en_b",
        "default": "0",
        "descr": "read enable port B",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "type": "input",
        "n_bits": "ADDR_W",
        "name": "addr_b",
        "default": "0",
        "descr": "address port B",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "type": "output",
        "n_bits": "DATA_W",
        "name": "r_data_b",
        "default": "0",
        "descr": "read data port B",
    },
]

ram_sp = [
    {
        "be": 1,
        "sp": 1,
        "type": "input",
        "n_bits": "1",
        "name": "clk",
        "default": "0",
        "descr": "clock",
    },
    {
        "be": 1,
        "sp": 1,
        "type": "input",
        "n_bits": "DATA_W",
        "name": "d",
        "default": "0",
        "descr": "ram sp data input",
    },
    {
        "be": 1,
        "sp": 1,
        "type": "input",
        "n_bits": "ADDR_W",
        "name": "addr",
        "default": "0",
        "descr": "ram sp address",
    },
    {
        "be": 1,
        "sp": 1,
        "type": "input",
        "n_bits": "1",
        "name": "en",
        "default": "0",
        "descr": "ram sp enable",
    },
    {
        "be": 1,
        "sp": 1,
        "type": "output",
        "n_bits": "DATA_W",
        "name": "d",
        "default": "0",
        "descr": "ram sp data output",
    },
    {
        "be": 0,
        "sp": 1,
        "type": "input",
        "n_bits": "1",
        "name": "we",
        "default": "0",
        "descr": "ram sp write enable",
    },
    {
        "be": 1,
        "sp": 0,
        "type": "input",
        "n_bits": "DATA_W/8",
        "name": "we",
        "default": "0",
        "descr": "ram sp write strobe",
    },
]

ram_2p = [
    {
        "2p": 1,
        "be": 1,
        "tiled": 1,
        "t2p": 0,
        "type": "input",
        "n_bits": "1",
        "name": "clk",
        "default": "0",
        "descr": "clock",
    },
    {
        "2p": 0,
        "be": 0,
        "tiled": 0,
        "t2p": 1,
        "type": "input",
        "n_bits": "1",
        "name": "w_clk",
        "default": "0",
        "descr": "write clock",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 1,
        "t2p": 1,
        "type": "input",
        "n_bits": "DATA_W",
        "name": "w_data",
        "default": "0",
        "descr": "ram 2p write data",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 0,
        "t2p": 1,
        "type": "input",
        "n_bits": "ADDR_W",
        "name": "w_addr",
        "default": "0",
        "descr": "ram 2p write address",
    },
    {
        "2p": 0,
        "be": 0,
        "tiled": 1,
        "t2p": 0,
        "type": "input",
        "n_bits": "ADDR_W",
        "name": "addr",
        "default": "0",
        "descr": "ram 2p address",
    },
    {
        "2p": 1,
        "be": 0,
        "tiled": 1,
        "t2p": 1,
        "type": "input",
        "n_bits": "1",
        "name": "w_en",
        "default": "0",
        "descr": "ram 2p write enable",
    },
    {
        "2p": 0,
        "be": 1,
        "tiled": 0,
        "t2p": 0,
        "type": "input",
        "n_bits": "DATA_W/8",
        "name": "w_en",
        "default": "0",
        "descr": "ram 2p write strobe",
    },
    {
        "2p": 0,
        "be": 0,
        "tiled": 0,
        "t2p": 1,
        "type": "input",
        "n_bits": "1",
        "name": "r_clk",
        "default": "0",
        "descr": "read clock",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 0,
        "t2p": 1,
        "type": "input",
        "n_bits": "ADDR_W",
        "name": "r_addr",
        "default": "0",
        "descr": "ram 2p read address",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 1,
        "t2p": 1,
        "type": "input",
        "n_bits": "1",
        "name": "r_en",
        "default": "0",
        "descr": "ram 2p read enable",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 1,
        "t2p": 1,
        "type": "output",
        "n_bits": "DATA_W",
        "name": "r_data",
        "default": "0",
        "descr": "ram 2p read data",
    },
]

ram_dp = [
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 0,
        "tdp_be": 0,
        "type": "input",
        "n_bits": "1",
        "name": "clk",
        "default": "0",
        "descr": "clock",
    },
    {
        "dp": 0,
        "dp_be": 0,
        "dp_be_xil": 0,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "n_bits": "1",
        "name": "clkA",
        "default": "0",
        "descr": "clock A",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "n_bits": "DATA_W",
        "name": "dA",
        "default": "0",
        "descr": "Data in A",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "n_bits": "ADDR_W",
        "name": "addrA",
        "default": "0",
        "descr": "Address A",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "n_bits": "1",
        "name": "enA",
        "default": "0",
        "descr": "Enable A",
    },
    {
        "dp": 1,
        "dp_be": 0,
        "dp_be_xil": 0,
        "tdp": 1,
        "tdp_be": 0,
        "type": "input",
        "n_bits": "1",
        "name": "weA",
        "default": "0",
        "descr": "Write enable A",
    },
    {
        "dp": 0,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 0,
        "tdp_be": 1,
        "type": "input",
        "n_bits": "DATA_W/8",
        "name": "weA",
        "default": "0",
        "descr": "Write strobe A",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "output",
        "n_bits": "DATA_W",
        "name": "dA",
        "default": "0",
        "descr": "Data out A",
    },
    {
        "dp": 0,
        "dp_be": 0,
        "dp_be_xil": 0,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "n_bits": "1",
        "name": "clkB",
        "default": "0",
        "descr": "clock B",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "n_bits": "DATA_W",
        "name": "dB",
        "default": "0",
        "descr": "Data in B",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "n_bits": "ADDR_W",
        "name": "addrB",
        "default": "0",
        "descr": "Address B",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "n_bits": "1",
        "name": "enB",
        "default": "0",
        "descr": "Enable B",
    },
    {
        "dp": 1,
        "dp_be": 0,
        "dp_be_xil": 0,
        "tdp": 1,
        "tdp_be": 0,
        "type": "input",
        "n_bits": "1",
        "name": "weB",
        "default": "0",
        "descr": "Write enable B",
    },
    {
        "dp": 0,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 0,
        "tdp_be": 1,
        "type": "input",
        "n_bits": "DATA_W/8",
        "name": "weB",
        "default": "0",
        "descr": "Write strobe B",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "output",
        "n_bits": "DATA_W",
        "name": "dB",
        "default": "0",
        "descr": "Data out B",
    },
]

#
# AXI4
#

AXI_SIZE_W = "3"
AXI_BURST_W = "2"
AXI_LOCK_W = "2"
AXI_CACHE_W = "4"
AXI_PROT_W = "3"
AXI_QOS_W = "4"
AXI_RESP_W = "2"

axi_write = [
    {
        "lite": 0,
        "type": "output",
        "n_bits": "AXI_ID_W",
        "name": "axi_awid",
        "default": "0",
        "descr": "Address write channel ID.",
    },
    {
        "lite": 1,
        "type": "output",
        "n_bits": "AXI_ADDR_W",
        "name": "axi_awaddr",
        "default": "0",
        "descr": "Address write channel address.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": "AXI_LEN_W",
        "name": "axi_awlen",
        "default": "0",
        "descr": "Address write channel burst length.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": AXI_SIZE_W,
        "name": "axi_awsize",
        "default": "2",
        "descr": "Address write channel burst size. This signal indicates the size of each transfer in the burst.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": AXI_BURST_W,
        "name": "axi_awburst",
        "default": "1",
        "descr": "Address write channel burst type.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": AXI_LOCK_W,
        "name": "axi_awlock",
        "default": "0",
        "descr": "Address write channel lock type.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": AXI_CACHE_W,
        "name": "axi_awcache",
        "default": "2",
        "descr": "Address write channel memory type. Set to 0000 if master output; ignored if slave input.",
    },
    {
        "lite": 1,
        "type": "output",
        "n_bits": AXI_PROT_W,
        "name": "axi_awprot",
        "default": "2",
        "descr": "Address write channel protection type. Set to 000 if master output; ignored if slave input.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": AXI_QOS_W,
        "name": "axi_awqos",
        "default": "0",
        "descr": "Address write channel quality of service.",
    },
    {
        "lite": 1,
        "type": "output",
        "n_bits": "1",
        "name": "axi_awvalid",
        "default": "0",
        "descr": "Address write channel valid.",
    },
    {
        "lite": 1,
        "type": "input",
        "n_bits": "1",
        "name": "axi_awready",
        "default": "1",
        "descr": "Address write channel ready.",
    },
    {
        "lite": 1,
        "type": "output",
        "n_bits": "AXI_DATA_W",
        "name": "axi_wdata",
        "default": "0",
        "descr": "Write channel data.",
    },
    {
        "lite": 1,
        "type": "output",
        "n_bits": "(AXI_DATA_W/8)",
        "name": "axi_wstrb",
        "default": "0",
        "descr": "Write channel write strobe.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": "1",
        "name": "axi_wlast",
        "default": "0",
        "descr": "Write channel last word flag.",
    },
    {
        "lite": 1,
        "type": "output",
        "n_bits": "1",
        "name": "axi_wvalid",
        "default": "0",
        "descr": "Write channel valid.",
    },
    {
        "lite": 1,
        "type": "input",
        "n_bits": "1",
        "name": "axi_wready",
        "default": "1",
        "descr": "Write channel ready.",
    },
    {
        "lite": 0,
        "type": "input",
        "n_bits": "AXI_ID_W",
        "name": "axi_bid",
        "default": "0",
        "descr": "Write response channel ID.",
    },
    {
        "lite": 1,
        "type": "input",
        "n_bits": AXI_RESP_W,
        "name": "axi_bresp",
        "default": "0",
        "descr": "Write response channel response.",
    },
    {
        "lite": 1,
        "type": "input",
        "n_bits": "1",
        "name": "axi_bvalid",
        "default": "0",
        "descr": "Write response channel valid.",
    },
    {
        "lite": 1,
        "type": "output",
        "n_bits": "1",
        "name": "axi_bready",
        "default": "1",
        "descr": "Write response channel ready.",
    },
]

axi_read = [
    {
        "lite": 0,
        "type": "output",
        "n_bits": "AXI_ID_W",
        "name": "axi_arid",
        "default": "0",
        "descr": "Address read channel ID.",
    },
    {
        "lite": 1,
        "type": "output",
        "n_bits": "AXI_ADDR_W",
        "name": "axi_araddr",
        "default": "0",
        "descr": "Address read channel address.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": "AXI_LEN_W",
        "name": "axi_arlen",
        "default": "0",
        "descr": "Address read channel burst length.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": AXI_SIZE_W,
        "name": "axi_arsize",
        "default": "2",
        "descr": "Address read channel burst size. This signal indicates the size of each transfer in the burst.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": AXI_BURST_W,
        "name": "axi_arburst",
        "default": "1",
        "descr": "Address read channel burst type.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": AXI_LOCK_W,
        "name": "axi_arlock",
        "default": "0",
        "descr": "Address read channel lock type.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": AXI_CACHE_W,
        "name": "axi_arcache",
        "default": "2",
        "descr": "Address read channel memory type. Set to 0000 if master output; ignored if slave input.",
    },
    {
        "lite": 1,
        "type": "output",
        "n_bits": AXI_PROT_W,
        "name": "axi_arprot",
        "default": "2",
        "descr": "Address read channel protection type. Set to 000 if master output; ignored if slave input.",
    },
    {
        "lite": 0,
        "type": "output",
        "n_bits": AXI_QOS_W,
        "name": "axi_arqos",
        "default": "0",
        "descr": "Address read channel quality of service.",
    },
    {
        "lite": 1,
        "type": "output",
        "n_bits": "1",
        "name": "axi_arvalid",
        "default": "0",
        "descr": "Address read channel valid.",
    },
    {
        "lite": 1,
        "type": "input",
        "n_bits": "1",
        "name": "axi_arready",
        "default": "1",
        "descr": "Address read channel ready.",
    },
    {
        "lite": 0,
        "type": "input",
        "n_bits": "AXI_ID_W",
        "name": "axi_rid",
        "default": "0",
        "descr": "Read channel ID.",
    },
    {
        "lite": 1,
        "type": "input",
        "n_bits": "AXI_DATA_W",
        "name": "axi_rdata",
        "default": "0",
        "descr": "Read channel data.",
    },
    {
        "lite": 1,
        "type": "input",
        "n_bits": AXI_RESP_W,
        "name": "axi_rresp",
        "default": "0",
        "descr": "Read channel response.",
    },
    {
        "lite": 0,
        "type": "input",
        "n_bits": "1",
        "name": "axi_rlast",
        "default": "0",
        "descr": "Read channel last word.",
    },
    {
        "lite": 1,
        "type": "input",
        "n_bits": "1",
        "name": "axi_rvalid",
        "default": "0",
        "descr": "Read channel valid.",
    },
    {
        "lite": 1,
        "type": "output",
        "n_bits": "1",
        "name": "axi_rready",
        "default": "1",
        "descr": "Read channel ready.",
    },
]

axi = axi_write + axi_read
axil = axi

axis = [
    {
        "name": "axis_tvalid",
        "type": "output",
        "n_bits": "1",
        "default": "0",
        "descr": "axis stream valid.",
    },
    {
        "name": "axis_tready",
        "type": "input",
        "n_bits": "1",
        "default": "1",
        "descr": "axis stream ready.",
    },
    {
        "name": "axis_tdata",
        "type": "output",
        "n_bits": "AXI_DATA_W",
        "default": "0",
        "descr": "axis stream data.",
    },
    {
        "name": "axis_tlast",
        "type": "output",
        "n_bits": "1",
        "default": "0",
        "descr": "axis stream last.",
    },
]        


#
# AMBA
#

AHB_BURST_W = "3"
AHB_PROT_W = "4"
AHB_SIZE_W = "3"
AHB_TRANS_W = "2"

ahb = [
    {
        "ahb": 1,
        "apb": 1,
        "type": "output",
        "n_bits": "AHB_ADDR_W",
        "name": "ahb_addr",
        "default": "0",
        "descr": "Byte address of the transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "type": "output",
        "n_bits": AHB_BURST_W,
        "name": "ahb_burst",
        "default": "0",
        "descr": "Burst type.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "type": "output",
        "n_bits": "1",
        "name": "ahb_mastlock",
        "default": "0",
        "descr": "Transfer is part of a lock sequence.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "type": "output",
        "n_bits": AHB_PROT_W,
        "name": "ahb_prot",
        "default": "1",
        "descr": "Protection type. Set to 0000 if master output; ignored if slave input.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "type": "output",
        "n_bits": AHB_SIZE_W,
        "name": "ahb_size",
        "default": "2",
        "descr": "Burst size. Indicates the size of each transfer in the burst.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "type": "output",
        "n_bits": "1",
        "name": "ahb_nonsec",
        "default": "0",
        "descr": "Non-secure transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "type": "output",
        "n_bits": "1",
        "name": "ahb_excl",
        "default": "0",
        "descr": "Exclusive transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "type": "output",
        "n_bits": "AHB_MASTER_W",
        "name": "ahb_master",
        "default": "0",
        "descr": "Master ID.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "type": "output",
        "n_bits": AHB_TRANS_W,
        "name": "ahb_trans",
        "default": "0",
        "descr": "Transfer type. Indicates the type of the transfer.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "type": "output",
        "n_bits": "1",
        "name": "ahb_sel",
        "default": "0",
        "descr": "Slave select.",
    },
    {
        "ahb": 0,
        "apb": 1,
        "type": "output",
        "n_bits": "1",
        "name": "ahb_enable",
        "default": "0",
        "descr": "Enable. Indicates the number of clock cycles of the transfer.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "type": "output",
        "n_bits": "1",
        "name": "ahb_write",
        "default": "0",
        "descr": "Write. Indicates the direction of the operation.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "type": "output",
        "n_bits": "AHB_DATA_W",
        "name": "ahb_wdata",
        "default": "0",
        "descr": "Write data.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "type": "output",
        "n_bits": "(AHB_DATA_W/8)",
        "name": "ahb_wstrb",
        "default": "0",
        "descr": "Write strobe.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "type": "input",
        "n_bits": "AHB_DATA_W",
        "name": "ahb_rdata",
        "default": "0",
        "descr": "Read data.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "type": "input",
        "n_bits": "1",
        "name": "ahb_ready",
        "default": "0",
        "descr": "Ready. Indicates the end of a transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "type": "output",
        "n_bits": "1",
        "name": "ahb_ready",
        "default": "0",
        "descr": "Ready input. Indicates the end of the last transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "type": "input",
        "n_bits": "1",
        "name": "ahb_resp",
        "default": "0",
        "descr": "Transfer response.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "type": "input",
        "n_bits": "1",
        "name": "ahb_exokay",
        "default": "1",
        "descr": "Exclusive transfer response.",
    },
    {
        "ahb": 0,
        "apb": 0,
        "type": "input",
        "n_bits": "1",
        "name": "ahb_slverr",
        "default": "0",
        "descr": "Slave error. Indicates if the transfer has falied.",
    },
]

apb = ahb

def get_ports(interface):

    if_name = get_if_name(interface)
    
    port_list = eval(if_name)
    
    for i in port_list:
        if if_name == "axil":
            if i["lite"] == 1:
                port_list[-1]["name"] = port_list[-1]["name"].replace("axi_", "axil_")
                port_list[-1]["n_bits"] = port_list[-1]["n_bits"].replace("AXI_", "AXIL_")
            else:
                port_list.remove(i)
        if if_name == "apb":
            if i["apb"] == 1:
                port_list[-1]["name"] = port_list[-1]["name"].replace("ahb_", "apb_")
                port_list[-1]["n_bits"] = port_list[-1]["n_bits"].replace("AHB_", "APB_")
            else:
                port_list.remove(i)

    return port_list


#
# Handle signal direction 
#

# reverse module signal direction
def reverse(direction):
    if direction == "input":
        return "output"
    elif direction == "output":
        return "input"
    else:
        print("ERROR: reverse_direction : invalid argument")
        quit()

#testbench signal direction
def tbsignal(direction):
    if direction == "input":
        return "wire"
    elif direction == "output":
        return "reg"
    else:
        print("ERROR: tb_reciprocal : invalid argument")
        quit()

#get suffix from direction 
def suffix(direction):
    if direction == "input" or direction == "reg":
        return "_i"
    elif direction == "output" or direction == "wire":
        return "_o"
    elif direction == "inout":
        return "_io"
    else:
        print("ERROR: invalid signal direction.")
        quit()

#
# Add a given prefix (in upppercase) to every parameter/macro found in the string
#

def add_param_prefix(string, param_prefix):
    return re.sub(r"([a-zA-Z_][\w_]*)", param_prefix.upper() + r"\g<1>", string)


#
# Port
#


# Write single port with given direction, bus width, and name to file
def write_port(direction, width, name, fout):
    fout.write(direction + width + name + "," + "\n")

def m_port(port_list, prefix, param_prefix, fout, bus_size=1):
    for i in range(len(port_list)):
        port_direction = port_list[i]["type"]
        name = prefix + port_list[i]["name"] + suffix(port_list[i]["type"])
        if bus_size == 1:
            width = port_list[i]["n_bits"]
        else:
            width = "(" + str(bus_size) + "*" + port_list[i]["n_bits"] + ")"
        width = add_param_prefix(width, param_prefix)
        bus_width = " [" + width + "-1:0] "
        # Write port
        write_port(port_direction, bus_width, name, fout)


def s_port(port_list, prefix, param_prefix, fout, bus_size=1):
    for i in range(len(port_list)):
        port_direction = reverse(port_list[i]["type"])
        name = prefix + port_list[i]["name"] + suffix(reverse(port_list[i]["type"]))
        if bus_size == 1:
            width = port_list[i]["n_bits"]
        else:
            width = "(" + str(bus_size) + "*" + port_list[i]["n_bits"] + ")"
        width = add_param_prefix(width, param_prefix)
        bus_width = " [" + width + "-1:0] "
        # Write port
        write_port(port_direction, bus_width, name, fout)


#
# Portmap
#


# Write portmap with given portname, wire name, bus start index and size to file
def write_portmap(port, connection_name, width, bus_start, bus_size, fout):
    if bus_size == 1:
        connection = connection_name
    else:
        bus_select_size = str(bus_size) + "*" + width
        if bus_start == 0:
            bus_start_index = str(0)
        else:
            bus_start_index = str(bus_start) + "*" + width
        connection = (
            connection_name + "[" + bus_start_index + "+:" + bus_select_size + "]"
        )
    fout.write("." + port + "(" + connection + "), //" + "\n")

def portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"]
        connection_name = wire_prefix + port_list[i]["name"]
        write_portmap(
            port,
            connection_name,
            port_list[i]["n_bits"],
            bus_start,
            bus_size,
            fout,
        )

def m_portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"] + suffix(port_list[i]["type"])
        connection_name = wire_prefix + port_list[i]["name"]
        write_portmap(
            port,
            connection_name,
            port_list[i]["n_bits"],
            bus_start,
            bus_size,
            fout,
        )


def s_portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"] + suffix(reverse(port_list[i]["type"]))
        connection_name = wire_prefix + port_list[i]["name"]
        write_portmap(
            port,
            connection_name,
            port_list[i]["n_bits"],
            bus_start,
            bus_size,
            fout,
        )


def m_m_portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"] + suffix(port_list[i]["type"])
        connection_name = (
            wire_prefix + port_list[i]["name"] + suffix(port_list[i]["type"])
        )
        write_portmap(
            port,
            connection_name,
            port_list[i]["n_bits"],
            bus_start,
            bus_size,
            fout,
        )


def s_s_portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"] + suffix(reverse(port_list[i]["type"]))
        connection_name = (
            wire_prefix + port_list[i]["name"] + suffix(reverse(port_list[i]["type"]))
        )
        write_portmap(
            port,
            connection_name,
            port_list[i]["n_bits"],
            bus_start,
            bus_size,
            fout,
        )

#
# Wire
#

# Write wire with given name, bus size, width to file
def write_wire(name, param_prefix, bus_size, width, fout):
    width = add_param_prefix(width, param_prefix)
    if bus_size == 1:
        bus_width = " [" + width + "-1:0] "
    else:
        bus_width = " [" + str(bus_size) + "*" + width + "-1:0] "
    fout.write("wire" + bus_width + name + "; //" + "\n")

# Write reg with given name, bus size, width, initial value to file
def write_reg(name, param_prefix, bus_size, width, default, fout):
    width = add_param_prefix(width, param_prefix)
    if bus_size == 1:
        bus_width = " [" + width + "-1:0] "
    else:
        bus_width = " [" + str(bus_size) + "*" + width + "-1:0] "
    fout.write("reg" + bus_width + name + " = " + default + "; //" + "\n")

# Write tb wire with given tb_signal, prefix, name, bus size, width to file
def write_tb_wire(
    tb_signal,
    prefix,
    name,
    param_prefix,
    bus_size,
    width,
    fout,
    default="0",
):
    signal_name = prefix + name + suffix(tb_signal)
    if tb_signal == "reg":
        write_reg(
            signal_name, param_prefix, bus_size, width, default, fout
        )
    else:
        write_wire(signal_name, param_prefix, bus_size, width, fout)


def wire(port_list, prefix, param_prefix, fout, bus_size=1):
    for i in range(len(port_list)):
        write_wire(
            prefix + port_list[i]["name"],
            param_prefix,
            bus_size,
            port_list[i]["n_bits"],
            fout,
        )


def m_tb_wire(port_list, prefix, param_prefix, fout, bus_size=1):
    for i in range(len(port_list)):
        tb_signal = tbsignal(port_list[i]["type"])
        write_tb_wire(
            tb_signal,
            prefix,
            port_list[i]["name"],
            param_prefix,
            bus_size,
            port_list[i]["n_bits"],
            fout,
            port_list[i]["default"],
        )
    fout.write("\n")


def s_tb_wire(port_list, prefix, param_prefix, fout, bus_size=1):
    for i in range(len(port_list)):
        tb_signal = tbsignal(reverse(port_list[i]["type"]))
        write_tb_wire(
            tb_signal,
            prefix,
            port_list[i]["name"],
            param_prefix,
            bus_size,
            port_list[i]["n_bits"],
            fout,
            port_list[i]["default"],
        )
    fout.write("\n")

def write_vs_contents(
        file_object,
        interface,
        port_list = [],
        port_prefix = "",
        wire_prefix = "",
        bus_size = 1,
        bus_start = 0,
):
    interface_type = get_if_type(interface)

    if port_list == []:
        port_list = get_ports(interface)
    
    param_prefix = port_prefix.upper()

    if interface_type.find("portmap") + 1:
        eval(
            interface_type
            + "(port_list, port_prefix, wire_prefix, file_object, bus_start=bus_start, bus_size=bus_size)"
        )
    elif interface_type.find("wire") + 1:
        eval(interface_type + "(port_list, wire_prefix, param_prefix, file_object, bus_size=bus_size)")
    else:
        eval(interface_type + "(port_list, port_prefix, param_prefix, file_object, bus_size=bus_size)")

def get_if_name(arg):
    for if_name in interface_names:
        if arg.startswith(if_name):
            return if_name
    if if_name == interface_names[-1]:
        print("Error: Interface type not found")
        sys.exit(1)

def get_if_type(arg):
    for if_type in interface_types:
        if arg.endswith(if_type):
            return if_type
    if if_type == interface_names[-1]:
        print("Error: Interface type not found")
        sys.exit(1)
        
#
# Parse command line arguments
#

def validate_nametype(arg):
    if get_if_name(arg) is None:
        raise argparse.ArgumentTypeError("Invalid interface name")
    return arg
    
def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Generates Verilog snippet files for a given interface",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "nametype",
        type = validate_nametype,
        help=f"Interface name and type. Available names: {', '.join(interface_names)}",
    )

    parser.add_argument(
        "file_prefix",
        nargs="?",
        help="""Output file prefix.""",
        default=""
    )
    parser.add_argument(
        "port_prefix",
        nargs="?",
        help="""Port prefix.""",
        default=""
    )

    parser.add_argument(
        "wire_prefix",
        nargs="?",
        help="""Wire prefix.""",
        default=""
    )

    return parser.parse_args()

#
# Main
#


def main():

    # parse and extract command line arguments
    args = parse_arguments()
    interface = args.nametype
    file_prefix = args.file_prefix
    port_prefix = args.port_prefix
    wire_prefix = args.wire_prefix
    
    # write .vs file
    fout = open(file_prefix + interface + ".vs", "w")
    
    write_vs_contents(fout, interface, [], port_prefix, wire_prefix)

    fout.close()

if __name__ == "__main__":
    main()
