#!/usr/bin/env python3

# this script generates interfaces for Verilog modules and testbenches
# to add a new interface, add the name to the interface_names list, and an interface dictionary as below
# run this script with the -h option for help

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

#
# Interface dictionaries
#

iob = [
    {
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "iob_avalid",
        "default": "0",
        "description": "Request valid.",
    },
    {
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "ADDR_W",
        "name": "iob_addr",
        "default": "0",
        "description": "Address.",
    },
    {
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "DATA_W",
        "name": "iob_wdata",
        "default": "0",
        "description": "Write data.",
    },
    {
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "(DATA_W/8)",
        "name": "iob_wstrb",
        "default": "0",
        "description": "Write strobe.",
    },
    {
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "1",
        "name": "iob_rvalid",
        "default": "0",
        "description": "Read data valid.",
    },
    {
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "DATA_W",
        "name": "iob_rdata",
        "default": "0",
        "description": "Read data.",
    },
    {
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "1",
        "name": "iob_ready",
        "default": "0",
        "description": "Interface ready.",
    },
]

clk_rst = [
    {
        "master": 1,
        "slave": 1,
        "enable": 0,
        "type": "output",
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock signal",
    },
    {
        "master": 1,
        "slave": 1,
        "enable": 0,
        "type": "output",
        "width": "1",
        "name": "arst",
        "default": "0",
        "description": "asynchronous reset",
    },
]

clk_en_rst = [
    {
        "master": 1,
        "slave": 1,
        "enable": 0,
        "type": "output",
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock signal",
    },
    {
        "master": 1,
        "slave": 1,
        "enable": 1,
        "type": "output",
        "width": "1",
        "name": "cke",
        "default": "0",
        "description": "clock enable",
    },
    {
        "master": 1,
        "slave": 1,
        "enable": 0,
        "type": "output",
        "width": "1",
        "name": "arst",
        "default": "0",
        "description": "asynchronous reset",
    },
]

rom = [
    {
        "sp": 1,
        "tdp": 0,
        "dp": 1,
        "type": "input",
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock",
    },
    {
        "sp": 1,
        "tdp": 0,
        "dp": 0,
        "type": "input",
        "width": "1",
        "name": "r_en",
        "default": "0",
        "description": "read enable",
    },
    {
        "sp": 1,
        "tdp": 0,
        "dp": 0,
        "type": "input",
        "width": "ADDR_W",
        "name": "addr",
        "default": "0",
        "description": "address",
    },
    {
        "sp": 1,
        "tdp": 0,
        "dp": 0,
        "type": "output",
        "width": "DATA_W",
        "name": "r_data",
        "default": "0",
        "description": "read data",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 0,
        "type": "input",
        "width": "1",
        "name": "clk_a",
        "default": "0",
        "description": "clock port A",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 0,
        "type": "input",
        "width": "1",
        "name": "clk_b",
        "default": "0",
        "description": "clock port B",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "type": "input",
        "width": "1",
        "name": "r_en_a",
        "default": "0",
        "description": "read enable port A",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "type": "input",
        "width": "ADDR_W",
        "name": "addr_a",
        "default": "0",
        "description": "address port A",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "type": "output",
        "width": "DATA_W",
        "name": "r_data_a",
        "default": "0",
        "description": "read data port A",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "type": "input",
        "width": "1",
        "name": "r_en_b",
        "default": "0",
        "description": "read enable port B",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "type": "input",
        "width": "ADDR_W",
        "name": "addr_b",
        "default": "0",
        "description": "address port B",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "type": "output",
        "width": "DATA_W",
        "name": "r_data_b",
        "default": "0",
        "description": "read data port B",
    },
]

ram_sp = [
    {
        "be": 1,
        "sp": 1,
        "type": "input",
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock",
    },
    {
        "be": 1,
        "sp": 1,
        "type": "input",
        "width": "DATA_W",
        "name": "d",
        "default": "0",
        "description": "ram sp data input",
    },
    {
        "be": 1,
        "sp": 1,
        "type": "input",
        "width": "ADDR_W",
        "name": "addr",
        "default": "0",
        "description": "ram sp address",
    },
    {
        "be": 1,
        "sp": 1,
        "type": "input",
        "width": "1",
        "name": "en",
        "default": "0",
        "description": "ram sp enable",
    },
    {
        "be": 1,
        "sp": 1,
        "type": "output",
        "width": "DATA_W",
        "name": "d",
        "default": "0",
        "description": "ram sp data output",
    },
    {
        "be": 0,
        "sp": 1,
        "type": "input",
        "width": "1",
        "name": "we",
        "default": "0",
        "description": "ram sp write enable",
    },
    {
        "be": 1,
        "sp": 0,
        "type": "input",
        "width": "DATA_W/8",
        "name": "we",
        "default": "0",
        "description": "ram sp write strobe",
    },
]

ram_2p = [
    {
        "2p": 1,
        "be": 1,
        "tiled": 1,
        "t2p": 0,
        "type": "input",
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock",
    },
    {
        "2p": 0,
        "be": 0,
        "tiled": 0,
        "t2p": 1,
        "type": "input",
        "width": "1",
        "name": "w_clk",
        "default": "0",
        "description": "write clock",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 1,
        "t2p": 1,
        "type": "input",
        "width": "DATA_W",
        "name": "w_data",
        "default": "0",
        "description": "ram 2p write data",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 0,
        "t2p": 1,
        "type": "input",
        "width": "ADDR_W",
        "name": "w_addr",
        "default": "0",
        "description": "ram 2p write address",
    },
    {
        "2p": 0,
        "be": 0,
        "tiled": 1,
        "t2p": 0,
        "type": "input",
        "width": "ADDR_W",
        "name": "addr",
        "default": "0",
        "description": "ram 2p address",
    },
    {
        "2p": 1,
        "be": 0,
        "tiled": 1,
        "t2p": 1,
        "type": "input",
        "width": "1",
        "name": "w_en",
        "default": "0",
        "description": "ram 2p write enable",
    },
    {
        "2p": 0,
        "be": 1,
        "tiled": 0,
        "t2p": 0,
        "type": "input",
        "width": "DATA_W/8",
        "name": "w_en",
        "default": "0",
        "description": "ram 2p write strobe",
    },
    {
        "2p": 0,
        "be": 0,
        "tiled": 0,
        "t2p": 1,
        "type": "input",
        "width": "1",
        "name": "r_clk",
        "default": "0",
        "description": "read clock",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 0,
        "t2p": 1,
        "type": "input",
        "width": "ADDR_W",
        "name": "r_addr",
        "default": "0",
        "description": "ram 2p read address",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 1,
        "t2p": 1,
        "type": "input",
        "width": "1",
        "name": "r_en",
        "default": "0",
        "description": "ram 2p read enable",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 1,
        "t2p": 1,
        "type": "output",
        "width": "DATA_W",
        "name": "r_data",
        "default": "0",
        "description": "ram 2p read data",
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
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock",
    },
    {
        "dp": 0,
        "dp_be": 0,
        "dp_be_xil": 0,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "width": "1",
        "name": "clkA",
        "default": "0",
        "description": "clock A",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "width": "DATA_W",
        "name": "dA",
        "default": "0",
        "description": "Data in A",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "width": "ADDR_W",
        "name": "addrA",
        "default": "0",
        "description": "Address A",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "width": "1",
        "name": "enA",
        "default": "0",
        "description": "Enable A",
    },
    {
        "dp": 1,
        "dp_be": 0,
        "dp_be_xil": 0,
        "tdp": 1,
        "tdp_be": 0,
        "type": "input",
        "width": "1",
        "name": "weA",
        "default": "0",
        "description": "Write enable A",
    },
    {
        "dp": 0,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 0,
        "tdp_be": 1,
        "type": "input",
        "width": "DATA_W/8",
        "name": "weA",
        "default": "0",
        "description": "Write strobe A",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "output",
        "width": "DATA_W",
        "name": "dA",
        "default": "0",
        "description": "Data out A",
    },
    {
        "dp": 0,
        "dp_be": 0,
        "dp_be_xil": 0,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "width": "1",
        "name": "clkB",
        "default": "0",
        "description": "clock B",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "width": "DATA_W",
        "name": "dB",
        "default": "0",
        "description": "Data in B",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "width": "ADDR_W",
        "name": "addrB",
        "default": "0",
        "description": "Address B",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "input",
        "width": "1",
        "name": "enB",
        "default": "0",
        "description": "Enable B",
    },
    {
        "dp": 1,
        "dp_be": 0,
        "dp_be_xil": 0,
        "tdp": 1,
        "tdp_be": 0,
        "type": "input",
        "width": "1",
        "name": "weB",
        "default": "0",
        "description": "Write enable B",
    },
    {
        "dp": 0,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 0,
        "tdp_be": 1,
        "type": "input",
        "width": "DATA_W/8",
        "name": "weB",
        "default": "0",
        "description": "Write strobe B",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "type": "output",
        "width": "DATA_W",
        "name": "dB",
        "default": "0",
        "description": "Data out B",
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
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "AXI_ID_W",
        "name": "axi_awid",
        "default": "0",
        "description": "Address write channel ID.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "AXI_ADDR_W",
        "name": "axi_awaddr",
        "default": "0",
        "description": "Address write channel address.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "AXI_LEN_W",
        "name": "axi_awlen",
        "default": "0",
        "description": "Address write channel burst length.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AXI_SIZE_W,
        "name": "axi_awsize",
        "default": "2",
        "description": "Address write channel burst size. This signal indicates the size of each transfer in the burst.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AXI_BURST_W,
        "name": "axi_awburst",
        "default": "1",
        "description": "Address write channel burst type.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AXI_LOCK_W,
        "name": "axi_awlock",
        "default": "0",
        "description": "Address write channel lock type.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AXI_CACHE_W,
        "name": "axi_awcache",
        "default": "2",
        "description": "Address write channel memory type. Set to 0000 if master output; ignored if slave input.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AXI_PROT_W,
        "name": "axi_awprot",
        "default": "2",
        "description": "Address write channel protection type. Set to 000 if master output; ignored if slave input.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AXI_QOS_W,
        "name": "axi_awqos",
        "default": "0",
        "description": "Address write channel quality of service.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "axi_awvalid",
        "default": "0",
        "description": "Address write channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "1",
        "name": "axi_awready",
        "default": "1",
        "description": "Address write channel ready.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "AXI_DATA_W",
        "name": "axi_wdata",
        "default": "0",
        "description": "Write channel data.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "(AXI_DATA_W/8)",
        "name": "axi_wstrb",
        "default": "0",
        "description": "Write channel write strobe.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "axi_wlast",
        "default": "0",
        "description": "Write channel last word flag.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "axi_wvalid",
        "default": "0",
        "description": "Write channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "1",
        "name": "axi_wready",
        "default": "1",
        "description": "Write channel ready.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "AXI_ID_W",
        "name": "axi_bid",
        "default": "0",
        "description": "Write response channel ID.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": AXI_RESP_W,
        "name": "axi_bresp",
        "default": "0",
        "description": "Write response channel response.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "1",
        "name": "axi_bvalid",
        "default": "0",
        "description": "Write response channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "axi_bready",
        "default": "1",
        "description": "Write response channel ready.",
    },
]

axi_read = [
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "AXI_ID_W",
        "name": "axi_arid",
        "default": "0",
        "description": "Address read channel ID.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "AXI_ADDR_W",
        "name": "axi_araddr",
        "default": "0",
        "description": "Address read channel address.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "AXI_LEN_W",
        "name": "axi_arlen",
        "default": "0",
        "description": "Address read channel burst length.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AXI_SIZE_W,
        "name": "axi_arsize",
        "default": "2",
        "description": "Address read channel burst size. This signal indicates the size of each transfer in the burst.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AXI_BURST_W,
        "name": "axi_arburst",
        "default": "1",
        "description": "Address read channel burst type.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AXI_LOCK_W,
        "name": "axi_arlock",
        "default": "0",
        "description": "Address read channel lock type.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AXI_CACHE_W,
        "name": "axi_arcache",
        "default": "2",
        "description": "Address read channel memory type. Set to 0000 if master output; ignored if slave input.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AXI_PROT_W,
        "name": "axi_arprot",
        "default": "2",
        "description": "Address read channel protection type. Set to 000 if master output; ignored if slave input.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AXI_QOS_W,
        "name": "axi_arqos",
        "default": "0",
        "description": "Address read channel quality of service.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "axi_arvalid",
        "default": "0",
        "description": "Address read channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "1",
        "name": "axi_arready",
        "default": "1",
        "description": "Address read channel ready.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "AXI_ID_W",
        "name": "axi_rid",
        "default": "0",
        "description": "Read channel ID.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "AXI_DATA_W",
        "name": "axi_rdata",
        "default": "0",
        "description": "Read channel data.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": AXI_RESP_W,
        "name": "axi_rresp",
        "default": "0",
        "description": "Read channel response.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "1",
        "name": "axi_rlast",
        "default": "0",
        "description": "Read channel last word.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "1",
        "name": "axi_rvalid",
        "default": "0",
        "description": "Read channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "axi_rready",
        "default": "1",
        "description": "Read channel ready.",
    },
]

axi = axi_write + axi_read
axil = axi

axis = [
    {
        "name": "axis_tvalid",
        "type": "output",
        "width": "1",
        "default": "0",
        "description": "axis stream valid.",
    },
    {
        "name": "axis_tready",
        "type": "input",
        "width": "1",
        "default": "1",
        "description": "axis stream ready.",
    },
    {
        "name": "axis_tdata",
        "type": "output",
        "width": "AXI_DATA_W",
        "default": "0",
        "description": "axis stream data.",
    },
    {
        "name": "axis_tlast",
        "type": "output",
        "width": "1",
        "default": "0",
        "description": "axis stream last.",
    },
]        


#
# AMBA
#

AHB_BURST_W = "3"
AHB_PROT_W = "4"
AHB_SIZE_W = "3"
AHB_TRANS_W = "2"

amba = [
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "AHB_ADDR_W",
        "name": "ahb_addr",
        "default": "0",
        "description": "Byte address of the transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AHB_BURST_W,
        "name": "ahb_burst",
        "default": "0",
        "description": "Burst type.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "ahb_mastlock",
        "default": "0",
        "description": "Transfer is part of a lock sequence.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AHB_PROT_W,
        "name": "ahb_prot",
        "default": "1",
        "description": "Protection type. Set to 0000 if master output; ignored if slave input.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AHB_SIZE_W,
        "name": "ahb_size",
        "default": "2",
        "description": "Burst size. Indicates the size of each transfer in the burst.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "ahb_nonsec",
        "default": "0",
        "description": "Non-secure transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "ahb_excl",
        "default": "0",
        "description": "Exclusive transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "AHB_MASTER_W",
        "name": "ahb_master",
        "default": "0",
        "description": "Master ID.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": AHB_TRANS_W,
        "name": "ahb_trans",
        "default": "0",
        "description": "Transfer type. Indicates the type of the transfer.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "ahb_sel",
        "default": "0",
        "description": "Slave select.",
    },
    {
        "ahb": 0,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "ahb_enable",
        "default": "0",
        "description": "Enable. Indicates the number of clock cycles of the transfer.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "ahb_write",
        "default": "0",
        "description": "Write. Indicates the direction of the operation.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "AHB_DATA_W",
        "name": "ahb_wdata",
        "default": "0",
        "description": "Write data.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "type": "output",
        "width": "(AHB_DATA_W/8)",
        "name": "ahb_wstrb",
        "default": "0",
        "description": "Write strobe.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "AHB_DATA_W",
        "name": "ahb_rdata",
        "default": "0",
        "description": "Read data.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "1",
        "name": "ahb_ready",
        "default": "0",
        "description": "Ready. Indicates the end of a transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 0,
        "slave": 1,
        "type": "output",
        "width": "1",
        "name": "ahb_ready",
        "default": "0",
        "description": "Ready input. Indicates the end of the last transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "1",
        "name": "ahb_resp",
        "default": "0",
        "description": "Transfer response.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "1",
        "name": "ahb_exokay",
        "default": "1",
        "description": "Exclusive transfer response.",
    },
    {
        "ahb": 0,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "type": "input",
        "width": "1",
        "name": "ahb_slverr",
        "default": "0",
        "description": "Slave error. Indicates if the transfer has falied.",
    },
]

ahb = amba
apb = amba


#interface name and table global variable
table = []

def create_table(interface_name):

    global table

    table = eval(interface_name)
    
    for i in table:
        if interface_name == "axil":
            if i["lite"] == 1:
                table[-1]["name"] = table[-1]["name"].replace("axi_", "axil_")
                table[-1]["width"] = table[-1]["width"].replace("AXI_", "AXIL_")
            else:
                table.remove(i)
        if interface_name == "apb":
            if i["apb"] == 1:
                table[-1]["name"] = table[-1]["name"].replace("ahb_", "apb_")
                table[-1]["width"] = table[-1]["width"].replace("AHB_", "APB_")
            else:
                table.remove(i)

    return table

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

#reverse testbench signal direction
def tbsignal(direction):
    if direction == "input":
        return "wire"
    elif direction == "output":
        return "reg"
    else:
        print("ERROR: tb_reciprocal : invalid argument")
        quit()

#apply direction direction 
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


# Write port with given direction, bus width, and name to file
def write_port(direction, width, name, fout):
    fout.write(direction + width + name + "," + "\n")

def m_port(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        if table[i]["master"] == 1:
            port_direction = table[i]["type"]
            name = prefix + table[i]["name"] + suffix(table[i]["type"])
            if bus_size == 1:
                width = table[i]["width"]
            else:
                width = "(" + str(bus_size) + "*" + table[i]["width"] + ")"
            width = add_param_prefix(width, param_prefix)
            bus_width = " [" + width + "-1:0] "
            # Write port
            write_port(port_direction, bus_width, name, fout)


def s_port(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        if table[i]["slave"] == 1:
            port_direction = reverse(table[i]["type"])
            name = prefix + table[i]["name"] + suffix(reverse(table[i]["type"]))
            if bus_size == 1:
                width = table[i]["width"]
            else:
                width = "(" + str(bus_size) + "*" + table[i]["width"] + ")"
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

def portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        port = port_prefix + table[i]["name"]
        connection_name = wire_prefix + table[i]["name"]
        write_portmap(
            port,
            connection_name,
            table[i]["width"],
            bus_start,
            bus_size,
            fout,
        )

def m_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["master"] == 1:
            port = port_prefix + table[i]["name"] + suffix(table[i]["type"])
            connection_name = wire_prefix + table[i]["name"]
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
                bus_start,
                bus_size,
                fout,
            )


def s_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["slave"] == 1:
            port = port_prefix + table[i]["name"] + suffix(reverse(table[i]["type"]))
            connection_name = wire_prefix + table[i]["name"]
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
                bus_start,
                bus_size,
                fout,
            )


def m_m_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["master"] == 1:
            port = port_prefix + table[i]["name"] + suffix(table[i]["type"])
            connection_name = (
                wire_prefix + table[i]["name"] + suffix(table[i]["type"])
            )
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
                bus_start,
                bus_size,
                fout,
            )


def s_s_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["slave"] == 1:
            port = port_prefix + table[i]["name"] + suffix(reverse(table[i]["type"]))
            connection_name = (
                wire_prefix + table[i]["name"] + suffix(reverse(table[i]["type"]))
            )
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
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


def wire(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        write_wire(
            prefix + table[i]["name"],
            param_prefix,
            bus_size,
            table[i]["width"],
            fout,
        )


def m_tb_wire(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        if table[i]["slave"] == 1:
            tb_signal = tbsignal(table[i]["type"])
            write_tb_wire(
                tb_signal,
                prefix,
                table[i]["name"],
                param_prefix,
                bus_size,
                table[i]["width"],
                fout,
                table[i]["default"],
            )
    fout.write("\n")


def s_tb_wire(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        if table[i]["master"] == 1:
            tb_signal = tbsignal(reverse(table[i]["type"]))
            write_tb_wire(
                tb_signal,
                prefix,
                table[i]["name"],
                param_prefix,
                bus_size,
                table[i]["width"],
                fout,
                table[i]["default"],
            )
    fout.write("\n")

# port_prefix: Prefix for ports in a portmap file; Prefix for ports in a `*port.vs` file; Use PORT_PREFIX (upper case) for parameters in signal width for ports or wire.
# wire_prefix: Prefix for wires in a portmap file; Prefix for wires in a `*wires.vs` file;
def write_vs_contents(
        sig_table,
        interface_type,
        port_prefix,
        wire_prefix,
        file_object,
        bus_size=1,
        bus_start=0,
):
    global table
    table = sig_table

    param_prefix = port_prefix.upper()

    if interface_type.find("portmap") + 1:
        eval(
            interface_type
            + "(port_prefix, wire_prefix, file_object, bus_start=bus_start, bus_size=bus_size)"
        )
    elif interface_type.find("wire") + 1:
        eval(interface_type + "(wire_prefix, param_prefix, file_object, bus_size=bus_size)")
    else:
        eval(interface_type + "(port_prefix, param_prefix, file_object, bus_size=bus_size)")

def get_if_name(arg):
    for interface in interface_names:
        if arg.startswith(interface):
            return interface
    if interface == interface_names[-1]:
        return None

def get_if_type(arg):
    for interface in interface_names:
        if arg.startswith(interface):
            return arg[len(interface):]
    if interface == interface_names[-1]:
        return None
        
#
# Parse command line arguments
#
        
def parse_arguments():
    parser = argparse.ArgumentParser(
        description="description: generates interface files for a given interface",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "type",
        help="""
        type can defined as one of the following: 
        base_m_port: iob native master port, 
        base_s_port: iob native slave port, 
        base_s_s_portmap: iob native portmap, 
        base_m_portmap: iob native master portmap, 
        base_s_portmap: iob native slave portmap, 
        base_m_m_portmap: iob native master to master portmap, 
        base_s_s_portmap: iob native slave to slave portmap\
        base_wire: iob native wires for interconnection, 
        base_m_tb_wire: iob native master wires for testbench, 
        base_s_tb_wire: iob native slave wires for testbench; 
        
        where base is one of the following: 
  
        """,
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

    # parse command line arguments
    args = parse_arguments()

    # create signal table
    interface_name = get_if_name(args.type)
    create_table(interface_name)

    # write .vs file
    fout = open(args.file_prefix + args.type + ".vs", "w")
    write_vs_contents(table, interface_name, args.port_prefix, args.wire_prefix, fout)

    fout.close()

if __name__ == "__main__":
    main()
