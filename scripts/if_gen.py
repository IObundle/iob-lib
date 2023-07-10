#!/usr/bin/env python3

# Generates IOb Native, AXI4 Full and AXI4 Lite ports, port maps and signals
#
#   See "Usage" below
#

import sys
import argparse
import re

table = []

interfaces = [
    "iob_m_port",
    "iob_s_port",
    "iob_portmap",
    "iob_m_portmap",
    "iob_s_portmap",
    "iob_m_m_portmap",
    "iob_s_s_portmap",
    "iob_wire",
    "iob_m_tb_wire",
    "iob_s_tb_wire",
    "clk_en_rst_port",
    "clk_rst_port",
    "clk_en_rst_portmap",
    "clk_rst_portmap",
    "axi_m_port",
    "axi_s_port",
    "axi_m_write_port",
    "axi_s_write_port",
    "axi_m_read_port",
    "axi_s_read_port",
    "axi_portmap",
    "axi_m_portmap",
    "axi_s_portmap",
    "axi_m_m_portmap",
    "axi_s_s_portmap",
    "axi_m_write_portmap",
    "axi_s_write_portmap",
    "axi_m_m_write_portmap",
    "axi_s_s_write_portmap",
    "axi_m_read_portmap",
    "axi_s_read_portmap",
    "axi_m_m_read_portmap",
    "axi_s_s_read_portmap",
    "axi_wire",
    "axi_m_tb_wire",
    "axi_s_tb_wire",
    "axil_m_port",
    "axil_s_port",
    "axil_m_write_port",
    "axil_s_write_port",
    "axil_m_read_port",
    "axil_s_read_port",
    "axil_portmap",
    "axil_m_portmap",
    "axil_s_portmap",
    "axil_m_m_portmap",
    "axil_s_s_portmap",
    "axil_m_write_portmap",
    "axil_s_write_portmap",
    "axil_m_m_write_portmap",
    "axil_s_s_write_portmap",
    "axil_m_read_portmap",
    "axil_s_read_portmap",
    "axil_m_m_read_portmap",
    "axil_s_s_read_portmap",
    "axil_wire",
    "axil_m_tb_wire",
    "axil_s_tb_wire",
    "ahb_m_port",
    "ahb_s_port",
    "ahb_portmap",
    "ahb_m_portmap",
    "ahb_s_portmap",
    "ahb_m_m_portmap",
    "ahb_s_s_portmap",
    "ahb_wire",
    "ahb_m_tb_wire",
    "ahb_s_tb_wire",
    "apb_m_port",
    "apb_s_port",
    "apb_portmap",
    "apb_m_portmap",
    "apb_s_portmap",
    "apb_m_m_portmap",
    "apb_s_s_portmap",
    "apb_wire",
    "apb_m_tb_wire",
    "apb_s_tb_wire",
]

#
# IOb Native Bus Signals
#

iob = [
    {
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "iob_avalid",
        "default": "0",
        "description": "Request valid.",
    },
    {
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "ADDR_W",
        "name": "iob_addr",
        "default": "0",
        "description": "Address.",
    },
    {
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "DATA_W",
        "name": "iob_wdata",
        "default": "0",
        "description": "Write data.",
    },
    {
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "(DATA_W/8)",
        "name": "iob_wstrb",
        "default": "0",
        "description": "Write strobe.",
    },
    {
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "iob_rvalid",
        "default": "0",
        "description": "Read data valid.",
    },
    {
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "DATA_W",
        "name": "iob_rdata",
        "default": "0",
        "description": "Read data.",
    },
    {
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "iob_ready",
        "default": "0",
        "description": "Interface ready.",
    },
]

clk_en_rst = [
    {
        "enable": 0,
        "signal": "input",
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock signal",
    },
    {
        "enable": 1,
        "signal": "input",
        "width": "1",
        "name": "cke",
        "default": "0",
        "description": "clock enable",
    },
    {
        "enable": 0,
        "signal": "input",
        "width": "1",
        "name": "arst",
        "default": "0",
        "description": "asynchronous reset",
    },
]

#
# AXI4 Bus Signals
#

# bus constants
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
        "signal": "output",
        "width": "AXI_ID_W",
        "name": "axi_awid",
        "default": "0",
        "description": "Address write channel ID.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AXI_ADDR_W",
        "name": "axi_awaddr",
        "default": "0",
        "description": "Address write channel address.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AXI_LEN_W",
        "name": "axi_awlen",
        "default": "0",
        "description": "Address write channel burst length.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_SIZE_W,
        "name": "axi_awsize",
        "default": "2",
        "description": "Address write channel burst size. This signal indicates the size of each transfer in the burst.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_BURST_W,
        "name": "axi_awburst",
        "default": "1",
        "description": "Address write channel burst type.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_LOCK_W,
        "name": "axi_awlock",
        "default": "0",
        "description": "Address write channel lock type.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_CACHE_W,
        "name": "axi_awcache",
        "default": "2",
        "description": "Address write channel memory type. Set to 0000 if master output; ignored if slave input.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_PROT_W,
        "name": "axi_awprot",
        "default": "2",
        "description": "Address write channel protection type. Set to 000 if master output; ignored if slave input.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_QOS_W,
        "name": "axi_awqos",
        "default": "0",
        "description": "Address write channel quality of service.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "axi_awvalid",
        "default": "0",
        "description": "Address write channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "axi_awready",
        "default": "1",
        "description": "Address write channel ready.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AXI_DATA_W",
        "name": "axi_wdata",
        "default": "0",
        "description": "Write channel data.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "(AXI_DATA_W/8)",
        "name": "axi_wstrb",
        "default": "0",
        "description": "Write channel write strobe.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "axi_wlast",
        "default": "0",
        "description": "Write channel last word flag.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "axi_wvalid",
        "default": "0",
        "description": "Write channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "axi_wready",
        "default": "1",
        "description": "Write channel ready.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "AXI_ID_W",
        "name": "axi_bid",
        "default": "0",
        "description": "Write response channel ID.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": AXI_RESP_W,
        "name": "axi_bresp",
        "default": "0",
        "description": "Write response channel response.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "axi_bvalid",
        "default": "0",
        "description": "Write response channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
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
        "signal": "output",
        "width": "AXI_ID_W",
        "name": "axi_arid",
        "default": "0",
        "description": "Address read channel ID.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AXI_ADDR_W",
        "name": "axi_araddr",
        "default": "0",
        "description": "Address read channel address.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AXI_LEN_W",
        "name": "axi_arlen",
        "default": "0",
        "description": "Address read channel burst length.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_SIZE_W,
        "name": "axi_arsize",
        "default": "2",
        "description": "Address read channel burst size. This signal indicates the size of each transfer in the burst.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_BURST_W,
        "name": "axi_arburst",
        "default": "1",
        "description": "Address read channel burst type.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_LOCK_W,
        "name": "axi_arlock",
        "default": "0",
        "description": "Address read channel lock type.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_CACHE_W,
        "name": "axi_arcache",
        "default": "2",
        "description": "Address read channel memory type. Set to 0000 if master output; ignored if slave input.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_PROT_W,
        "name": "axi_arprot",
        "default": "2",
        "description": "Address read channel protection type. Set to 000 if master output; ignored if slave input.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_QOS_W,
        "name": "axi_arqos",
        "default": "0",
        "description": "Address read channel quality of service.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "axi_arvalid",
        "default": "0",
        "description": "Address read channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "axi_arready",
        "default": "1",
        "description": "Address read channel ready.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "AXI_ID_W",
        "name": "axi_rid",
        "default": "0",
        "description": "Read channel ID.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "AXI_DATA_W",
        "name": "axi_rdata",
        "default": "0",
        "description": "Read channel data.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": AXI_RESP_W,
        "name": "axi_rresp",
        "default": "0",
        "description": "Read channel response.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "axi_rlast",
        "default": "0",
        "description": "Read channel last word.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "axi_rvalid",
        "default": "0",
        "description": "Read channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "axi_rready",
        "default": "1",
        "description": "Read channel ready.",
    },
]

#
# AMBA Bus Signals
#

# bus constants
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "output",
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
        "signal": "input",
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
        "signal": "input",
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
        "signal": "output",
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
        "signal": "input",
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
        "signal": "input",
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
        "signal": "input",
        "width": "1",
        "name": "ahb_slverr",
        "default": "0",
        "description": "Slave error. Indicates if the transfer has falied.",
    },
]

top_macro = ""

#
# IOb Native
#


def make_iob():
    bus = []
    for i in range(len(iob)):
        bus.append(iob[i])
    return bus


#
# Clk En Rst
#


def make_clk_en_rst():
    bus = []
    for i in range(len(clk_en_rst)):
        bus.append(clk_en_rst[i])
    return bus


#
# AXI4 Full
#


def make_axi_write():
    bus = []
    for i in range(len(axi_write)):
        bus.append(axi_write[i])
    return bus


def make_axi_read():
    bus = []
    for i in range(len(axi_read)):
        bus.append(axi_read[i])
    return bus


def make_axi():
    return make_axi_write() + make_axi_read()


#
# AXI4 Lite
#


def make_axil_write():
    bus = []
    for signal in axi_write:
        if signal["lite"] == 1:
            bus.append(signal.copy())
            bus[-1]["name"] = bus[-1]["name"].replace("axi_", "axil_")
            bus[-1]["width"] = bus[-1]["width"].replace("AXI_", "AXIL_")
    return bus


def make_axil_read():
    bus = []
    for signal in axi_read:
        if signal["lite"] == 1:
            bus.append(signal.copy())
            bus[-1]["name"] = bus[-1]["name"].replace("axi_", "axil_")
            bus[-1]["width"] = bus[-1]["width"].replace("AXI_", "AXIL_")
    return bus


def make_axil():
    return make_axil_write() + make_axil_read()


#
# AHB
#


def make_ahb():
    bus = []
    for i in range(len(amba)):
        if amba[i]["ahb"] == 1:
            bus.append(amba[i])
    return bus


#
# APB
#


def make_apb():
    bus = []
    for i in range(len(amba)):
        if amba[i]["apb"] == 1:
            bus.append(amba[i])
            bus[-1]["name"] = bus[-1]["name"].replace("ahb_", "apb_")
            bus[-1]["width"] = bus[-1]["width"].replace("AHB_", "APB_")
    return bus


#
# Auxiliary Functions
#


def reverse(direction):
    if direction == "input":
        return "output"
    elif direction == "output":
        return "input"
    else:
        print("ERROR: reverse_direction : invalid argument")
        quit()


def tbsignal(direction):
    if direction == "input":
        return "wire"
    elif direction == "output":
        return "reg"
    else:
        print("ERROR: tb_reciprocal : invalid argument")
        quit()


def suffix(direction):
    if direction == "input" or direction == "reg":
        return "_i"
    elif direction == "output" or direction == "wire":
        return "_o"
    else:
        print("ERROR: get_signal_suffix : invalid argument")
        quit()


# Add a given prefix (in upppercase) to every parameter/macro found in the string
def add_param_prefix(string, param_prefix):
    return re.sub(r"([a-zA-Z_][\w_]*)", param_prefix.upper() + r"\g<1>", string)


#
# Port
#


# Write port with given direction, bus width, name and description to file
def write_port(direction, width, name, description, fout):
    fout.write(direction + width + name + "," + "\n")
    # fout.write(direction + width + name + ", //" + description + "\n")


def en_rst_port(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        port_direction = table[i]["signal"]
        name = prefix + table[i]["name"] + suffix(table[i]["signal"])
        width = table[i]["width"]
        bus_width = " [" + width + "-1:0] "
        description = top_macro + table[i]["description"]
        write_port(port_direction, bus_width, name, description, fout)


def rst_port(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        if table[i]["enable"] == 0:
            port_direction = table[i]["signal"]
            name = prefix + table[i]["name"] + suffix(table[i]["signal"])
            width = table[i]["width"]
            bus_width = " [" + width + "-1:0] "
            description = top_macro + table[i]["description"]
            write_port(port_direction, bus_width, name, description, fout)


def m_port(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        if table[i]["master"] == 1:
            port_direction = table[i]["signal"]
            name = prefix + table[i]["name"] + suffix(table[i]["signal"])
            if bus_size == 1:
                width = table[i]["width"]
            else:
                width = "(" + str(bus_size) + "*" + table[i]["width"] + ")"
            width = add_param_prefix(width, param_prefix)
            bus_width = " [" + width + "-1:0] "
            description = top_macro + table[i]["description"]
            # Write port
            write_port(port_direction, bus_width, name, description, fout)


def s_port(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        if table[i]["slave"] == 1:
            port_direction = reverse(table[i]["signal"])
            name = prefix + table[i]["name"] + suffix(reverse(table[i]["signal"]))
            if bus_size == 1:
                width = table[i]["width"]
            else:
                width = "(" + str(bus_size) + "*" + table[i]["width"] + ")"
            width = add_param_prefix(width, param_prefix)
            bus_width = " [" + width + "-1:0] "
            description = top_macro + table[i]["description"]
            # Write port
            write_port(port_direction, bus_width, name, description, fout)


#
# Portmap
#


# Write portmap with given port, connection name, width, bus start, bus size and description to file
def write_portmap(port, connection_name, width, bus_start, bus_size, description, fout):
    if bus_start == 0:
        bus_start_index = str(0)
    else:
        bus_start_index = str(bus_start) + "*" + width
    if bus_size == 1:
        bus_select_size = width
    else:
        bus_select_size = str(bus_size) + "*" + width
    connection = connection_name + "[" + bus_start_index + "+:" + bus_select_size + "]"
    fout.write("." + port + "(" + connection + "), //" + description + "\n")


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
            table[i]["description"],
            fout,
        )


def en_rst_portmap(port_prefix, wire_prefix, fout, bus_start, bus_size):
    for i in range(len(table)):
        port = port_prefix + table[i]["name"] + suffix(table[i]["signal"])
        connection_name = wire_prefix + table[i]["name"] + suffix(table[i]["signal"])
        write_portmap(
            port,
            connection_name,
            table[i]["width"],
            bus_start,
            bus_size,
            table[i]["description"],
            fout,
        )


def rst_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["enable"] == 0:
            port = port_prefix + table[i]["name"] + suffix(table[i]["signal"])
            connection_name = (
                wire_prefix + table[i]["name"] + suffix(table[i]["signal"])
            )
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
                bus_start,
                bus_size,
                table[i]["description"],
                fout,
            )


def m_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["master"] == 1:
            port = port_prefix + table[i]["name"] + suffix(table[i]["signal"])
            connection_name = wire_prefix + table[i]["name"]
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
                bus_start,
                bus_size,
                table[i]["description"],
                fout,
            )


def s_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["slave"] == 1:
            port = port_prefix + table[i]["name"] + suffix(reverse(table[i]["signal"]))
            connection_name = wire_prefix + table[i]["name"]
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
                bus_start,
                bus_size,
                table[i]["description"],
                fout,
            )


def m_m_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["master"] == 1:
            port = port_prefix + table[i]["name"] + suffix(table[i]["signal"])
            connection_name = (
                wire_prefix + table[i]["name"] + suffix(table[i]["signal"])
            )
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
                bus_start,
                bus_size,
                table[i]["description"],
                fout,
            )


def s_s_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["slave"] == 1:
            port = port_prefix + table[i]["name"] + suffix(reverse(table[i]["signal"]))
            connection_name = (
                wire_prefix + table[i]["name"] + suffix(reverse(table[i]["signal"]))
            )
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
                bus_start,
                bus_size,
                table[i]["description"],
                fout,
            )


#
# Wire
#


# Write wire with given name, bus size, width and description to file
def write_wire(name, param_prefix, bus_size, width, description, fout):
    width = add_param_prefix(width, param_prefix)
    if bus_size == 1:
        bus_width = " [" + width + "-1:0] "
    else:
        bus_width = " [" + str(bus_size) + "*" + width + "-1:0] "
    fout.write("wire" + bus_width + name + "; //" + description + "\n")


# Write reg with given name, bus size, width, initial value and description to file
def write_reg(name, param_prefix, bus_size, width, default, description, fout):
    width = add_param_prefix(width, param_prefix)
    if bus_size == 1:
        bus_width = " [" + width + "-1:0] "
    else:
        bus_width = " [" + str(bus_size) + "*" + width + "-1:0] "
    fout.write("reg" + bus_width + name + " = " + default + "; //" + description + "\n")


# Write tb wire with given tb_signal, prefix, name, bus size, width and description to file
def write_tb_wire(
    tb_signal,
    prefix,
    name,
    param_prefix,
    bus_size,
    width,
    description,
    fout,
    default="0",
):
    signal_name = prefix + name + suffix(tb_signal)
    if tb_signal == "reg":
        write_reg(
            signal_name, param_prefix, bus_size, width, default, description, fout
        )
    else:
        write_wire(signal_name, param_prefix, bus_size, width, description, fout)


def wire(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        write_wire(
            prefix + table[i]["name"],
            param_prefix,
            bus_size,
            table[i]["width"],
            table[i]["description"],
            fout,
        )


def m_tb_wire(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        if table[i]["slave"] == 1:
            tb_signal = tbsignal(table[i]["signal"])
            write_tb_wire(
                tb_signal,
                prefix,
                table[i]["name"],
                param_prefix,
                bus_size,
                table[i]["width"],
                table[i]["description"],
                fout,
                table[i]["default"],
            )
    fout.write("\n")


def s_tb_wire(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        if table[i]["master"] == 1:
            tb_signal = tbsignal(reverse(table[i]["signal"]))
            write_tb_wire(
                tb_signal,
                prefix,
                table[i]["name"],
                param_prefix,
                bus_size,
                table[i]["width"],
                table[i]["description"],
                fout,
                table[i]["default"],
            )
    fout.write("\n")


#
# Parse Arguments
#
def parse_arguments():
    parser = argparse.ArgumentParser(
        description="if_gen.py verilog interface generation.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "type",
        choices=interfaces,
        help="""
                            type can defined as one of the following:
                            iob_m_port: iob native master port
                            iob_s_port: iob native slave port
                            iob_portmap: iob native portmap
                            iob_m_portmap: iob native master portmap
                            iob_s_portmap: iob native slave portmap
                            iob_m_m_portmap: iob native master to master portmap
                            iob_s_s_portmap: iob native slave to slave portmap
                            iob_wire: iob native wires for interconnection
                            iob_m_tb_wire: iob native master wires for testbench
                            iob_s_tb_wire: iob native slave wires for testbench

                            clk_en_rst_port: clk, clk en, rst ports
                            clk_rst_port: clk, rst ports

                            axi_m_port: axi full master port
                            axi_s_port: axi full slave port
                            axi_m_write_port: axi full master write port
                            axi_s_write_port: axi full slave write port
                            axi_m_read_port: axi full master read port
                            axi_s_read_port: axi full slave read port
                            axi_portmap: axi full portmap
                            axi_m_portmap: axi full master portmap
                            axi_s_portmap: axi full slave portmap
                            axi_m_m_portmap: axi full master to master portmap
                            axi_s_s_portmap: axi full slave to slave portmap
                            axi_m_write_portmap: axi full master write portmap
                            axi_s_write_portmap: axi full slave write portmap
                            axi_m_m_write_portmap: axi full master to master write portmap
                            axi_s_s_write_portmap: axi full slave to slave write portmap
                            axi_m_read_portmap: axi full master read portmap
                            axi_s_read_portmap: axi full slave read portmap
                            axi_m_m_read_portmap: axi full master to master read portmap
                            axi_s_s_read_portmap: axi full slave to slave read portmap
                            axi_wire: axi full wires for interconnection
                            axi_m_tb_wire: axi full master wires for testbench
                            axi_s_tb_wire: axi full slave wires for testbench

                            axil_m_port: axi lite master port
                            axil_s_port: axi lite slave port
                            axil_m_write_port: axi lite master write port
                            axil_s_write_port: axi lite slave write port
                            axil_m_read_port: axi lite master read port
                            axil_s_read_port: axi lite slave read port
                            axil_portmap: axi lite portmap
                            axil_m_portmap: axi lite master portmap
                            axil_s_portmap: axi lite slave portmap
                            axil_m_m_portmap: axi lite master to master portmap
                            axil_s_s_portmap: axi lite slave to slave portmap
                            axil_m_write_portmap: axi lite master write portmap
                            axil_s_write_portmap: axi lite slave write portmap
                            axil_m_m_write_portmap: axi lite master to master write portmap
                            axil_s_s_write_portmap: axi lite slave to slave write portmap
                            axil_m_read_portmap: axi lite master read portmap
                            axil_s_read_portmap: axi lite slave read portmap
                            axil_m_m_read_portmap: axi lite master to master read portmap
                            axil_s_s_read_portmap: axi lite slave to slave read portmap
                            axil_wire: axi lite wires for interconnection
                            axil_m_tb_wire: axi lite master wires for testbench
                            axil_s_tb_wire: axi lite slave wires for testbench

                            ahb_m_port: ahb master port
                            ahb_s_port: ahb slave port
                            ahb_portmap: ahb portmap
                            ahb_m_portmap: ahb master portmap
                            ahb_s_portmap: ahb slave portmap
                            ahb_m_m_portmap: ahb master to master portmap
                            ahb_s_s_portmap: ahb slave to slave portmap
                            ahb_wire: ahb wires for interconnection
                            ahb_m_tb_wire: ahb master wires for testbench
                            ahb_s_tb_wire: ahb slave wires for testbench

                            apb_m_port: apb master port
                            apb_s_port: apb slave port
                            apb_portmap: apb portmap
                            apb_m_portmap: apb master portmap
                            apb_s_portmap: apb slave portmap
                            apb_m_m_portmap: apb master to master portmap
                            apb_s_s_portmap: apb slave to slave portmap
                            apb_wire: apb wires for interconnection
                            apb_m_tb_wire: apb master wires for testbench
                            apb_s_tb_wire: apb slave wires for testbench
                        """,
    )

    parser.add_argument(
        "file_prefix", nargs="?", help="""Output file prefix.""", default=""
    )
    parser.add_argument("port_prefix", nargs="?", help="""Port prefix.""", default="")
    parser.add_argument("wire_prefix", nargs="?", help="""Wire prefix.""", default="")
    parser.add_argument("--top", help="""Top Module interface.""", action="store_true")

    return parser.parse_args()


#
# Create signal table
#
def create_signal_table(interface_name):
    global table
    table = []

    if interface_name.find("iob_") >= 0:
        table = make_iob()

    if interface_name.find("clk_") >= 0:
        table = make_clk_en_rst()

    if interface_name.find("axi_") >= 0:
        if interface_name.find("write_") >= 0:
            table = make_axi_write()
        elif interface_name.find("read_") >= 0:
            table = make_axi_read()
        else:
            table = make_axi()

    if interface_name.find("axil_") >= 0:
        if interface_name.find("write_") >= 0:
            table = make_axil_write()
        elif interface_name.find("read_") >= 0:
            table = make_axil_read()
        else:
            table = make_axil()

    if interface_name.find("ahb_") >= 0:
        table = make_ahb()

    if interface_name.find("apb_") >= 0:
        table = make_apb()


#
# Write to .vs file
#


# port_prefix: Prefix for ports in a portmap file. Only used for portmaps.
# wire_prefix: Prefix for wires in a portmap file; Prefix for wires in a `*wires.vs` file; Prefix for ports in a `*port.vs` file (these ports also create wires);
# param_prefix: Prefix for parameters in signals width. Only used for ports or wires (unused for portmaps).
def write_vs_contents(
    interface_name,
    port_prefix,
    wire_prefix,
    file_object,
    param_prefix="",
    bus_size=1,
    bus_start=0,
):
    func_name = (
        interface_name.replace("axil_", "")
        .replace("clk_", "")
        .replace("axi_", "")
        .replace("write_", "")
        .replace("read_", "")
        .replace("iob_", "")
        .replace("apb_", "")
        .replace("ahb_", "")
    )
    if interface_name.find("portmap") + 1:
        eval(
            func_name
            + "(port_prefix, wire_prefix, file_object, bus_start=bus_start, bus_size=bus_size)"
        )
    else:
        eval(func_name + "(wire_prefix, param_prefix, file_object, bus_size=bus_size)")


#
# Main
#


def main():
    args = parse_arguments()

    # bus type
    interface_name = args.type

    # port and wire prefix
    file_prefix = args.file_prefix
    port_prefix = args.port_prefix
    wire_prefix = args.wire_prefix

    # top flag
    top = args.top
    if top:
        top_macro = "V2TEX_IO "

    # make AXI bus
    create_signal_table(interface_name)

    # open output .vs file
    fout = open(file_prefix + interface_name + ".vs", "w")

    # write pragma for doc production
    if interface_name.find("port") + 1 and not interface_name.find("portmap") + 1:
        fout.write("  //START_IO_TABLE " + port_prefix + interface_name + "\n")

    # call function func to generate .vs file
    write_vs_contents(interface_name, port_prefix, wire_prefix, fout)

    fout.close()


if __name__ == "__main__":
    main()
