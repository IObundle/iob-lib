#!/usr/bin/env python3

# this script generates interfaces for Verilog modules and testbenches to add a
# new standard interface, add the name to the interface_names list, and an
# interface dictionary as below run this script with the -h option for help

import sys
import argparse
import re

if_names = [
    "clk_en_rst",
    "clk_rst",
    "iob",
    "axil_read",
    "axil_write",
    "axil",
    "axi_read",
    "axi_write",
    "axi",
    "apb",
    "axis",
    "rom_sp",
    "rom_tdp",
    "ram_sp",
    "ram_tdp",
    "ram_2p",
]



if_types = [
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

DATA_W = 32
DATA_SECTION_W = 8
ADDR_W = 32

#
# below are functions that return interface ports for each interface type
# the port direction is relative to the master module (driver)
#

def get_iob_ports():
    return [
        {
            "name": "iob_avalid",
            "direction": "output",
            "width": 1,
            "descr": "Request address is valid.",
        },
        {
            "name": "iob_addr",
            "direction": "output",
            "width": ADDR_W,
            "descr": "Address.",
        },
        {
            "name": "iob_wdata",
            "direction": "output",
            "width": DATA_W,
            "descr": "Write data.",
        },
        {
            "name": "iob_wstrb",
            "direction": "output",
            "width": int(DATA_W/DATA_SECTION_W),
            "descr": "Write strobe.",
        },
        {
            "name": "iob_rvalid",
            "direction": "input",
            "width": 1,
            "descr": "Read data valid.",
        },
        {
            "name": "iob_rdata",
            "direction": "input",
            "width": DATA_W,
            "descr": "Read data.",
        },
        {
            "name": "iob_ready",
            "direction": "input",
            "width": 1,
            "descr": "Interface ready.",
        },
]

def get_clk_rst_ports():
    return [
        {
            "name": "clk",
            "direction": "output",
            "width": 1,
            "descr": "Clock",
        },
        {
            "name": "arst",
            "direction": "output",
            "width": 1,
            "descr": "Asynchronous active-high reset",
        },
    ]

def get_clk_en_rst_ports():
    return [
        {
            "name": "clk",
            "direction": "output",
            "width": 1,
            "descr": "Clock",
        },
        {
            "name": "cke",
            "direction": "output",
            "width": 1,
            "descr": "Enable",
        },
        {
            "name": "arst",
            "direction": "output",
            "width": 1,
            "descr": "Asynchronous active-high reset",
        },
    ]

def get_mem_read_ports(suffix):
    return [
        {
            "name": "clk_"+suffix,
            "direction": "output",
            "width": 1,
            "descr": f"Clock port {suffix}",
        },
        {
            "name": "en_"+suffix,
            "direction": "output",
            "width": 1,
            "descr": f"Enable port {suffix}",
        },
        {
            "name": "addr_a",
            "direction": "output",
            "width": ADDR_W,
            "descr": "Address port {suffix}",
        },
        {
            "name": "rdata_"+suffix,
            "direction": "input",
            "width": DATA_W,
            "descr": "Data port {suffix}",
        },
    ]
    

def get_mem_write_ports(suffix):
    return [
        {
            "name": "clk_"+suffix,
            "direction": "output",
            "width": 1,
            "descr": f"Clock port {suffix}",
        },
        {
            "name": "en_"+suffix,
            "direction": "output",
            "width": 1,
            "descr": f"Enable port {suffix}",
        },
        {
            "name": "addr_a",
            "direction": "output",
            "width": ADDR_W,
            "descr": "Address port {suffix}",
        },
        {
            "name": "wdata_"+suffix,
            "direction": "output",
            "width": DATA_W,
            "descr": "Data port {suffix}",
        },
        {
            "name": "wstrb_"+suffix,
            "direction": "output",
            "width": int(DATA_W/DATA_SECTION_W),
            "descr": "Write strobe port {suffix}",
        },
    ]

def get_rom_sp_ports():
    ports = get_mem_read_ports("") + get_mem_write_ports("")
    return [dict(t) for t in {tuple(d.items()) for d in ports}]


def get_rom_tdp_ports(port_prefix):
    return list(dict.fromkeys(
        get_mem_read_ports("a") +
        get_mem_read_ports("b")
    ))

def get_ram_sp_ports():
    return list(dict.fromkeys(
        get_mem_read_ports("") +
        get_mem_write_ports("")
    ))

def get_ram_tdp_ports():
    return list(dict.fromkeys(
        get_mem_read_ports("a") +
        get_mem_read_ports("b") +
        get_mem_write_ports("a") +
        get_mem_write_ports("b")
    ))

def get_ram_2p_ports(port_prefix):
    return list(dict.fromkeys(
        get_mem_write_ports("a") +
        get_mem_read_ports("b")
    ))
 
#
# AXI4
#
ID_W = 1
SIZE_W = 3
BURST_W = 2
LOCK_W = 2
CACHE_W = 4
PROT_W = 3
QOS_W = 4
RESP_W = 2
LEN_W = 8

def get_axil_write_ports ():
    return [
        {
            "name": "axil_awaddr",
            "direction": "output",
            "width": ADDR_W,
            "descr": "Address write channel address.",
        },
        {
            "name": "axil_awprot",
            "direction": "output",
            "width": PROT_W,
            "descr": "Address write channel protection type. Set to 000 if master output; ignored if slave input.",
        },
        {
            "name": "axil_awvalid",
            "direction": "output",
            "width": 1,
            "descr": "Address write channel valid.",
        },
        {
            "name": "axil_awready",
            "direction": "input",
            "width": 1,
            "descr": "Address write channel ready.",
        },
        {
            "name": "axil_wdata",
            "direction": "output",
            "width": DATA_W,
            "descr": "Write channel data.",
        },
        {
            "name": "axil_wstrb",
            "direction": "output",
            "width": int(DATA_W/DATA_SECTION_W),
            "descr": "Write channel write strobe.",
        },
        {
            "name": "axil_wvalid",
            "direction": "output",
            "width": 1,
            "descr": "Write channel valid.",
        },
        {
            "name": "axil_wready",
            "direction": "input",
            "width": 1,
            "descr": "Write channel ready.",
        },
        {
            "name": "axil_bresp",
            "direction": "input",
            "width": RESP_W,
            "descr": "Write response channel response.",
        },
        {
            "name": "axil_bvalid",
            "direction": "input",
            "width": 1,
            "descr": "Write response channel valid.",
        },
        {
            "name": "axil_bready",
            "direction": "output",
            "width": 1,
            "descr": "Write response channel ready.",
        },
    ]

def get_axil_read_ports():
    return [
    {
        "name": "axil_araddr",
        "direction": "output",
        "width": ADDR_W,
        "descr": "Address read channel address.",
    },
    {
        "name": "axil_arprot",
        "direction": "output",
        "width": PROT_W,
        "descr": "Address read channel protection type. Set to 000 if master output; ignored if slave input.",
    },
    {
        "name": "axil_arvalid",
        "direction": "output",
        "width": 1,
        "descr": "Address read channel valid.",
    },
    {
        "name": "axil_arready",
        "direction": "input",
        "width": 1,
        "descr": "Address read channel ready.",
    },
    {
        "name": "axil_rdata",
        "direction": "input",
        "width": DATA_W,
        "descr": "Read channel data.",
    },
    {
        "name": "axil_rresp",
        "direction": "input",
        "width": RESP_W,
        "descr": "Read channel response.",
    },
    {
        "name": "axil_rvalid",
        "direction": "input",
        "width": 1,
        "descr": "Read channel valid.",
    },
    {
        "name": "axil_rready",
        "direction": "output",
        "width": 1,
        "descr": "Read channel ready.",
    },
]


def get_axil_ports():
    return (get_axil_read_ports() + get_axil_write_ports())


def get_axi_write_ports ():

    axil_write = get_axil_write_ports()

    for port in axil_write:
        port["name"] = port["name"].replace("axil", "axi")
        
    return axil_write + [
        {
            "name": "axi_awid",
            "direction": "output",
            "width": ID_W,
            "descr": "Address write channel ID.",
        },
        {
            "name": "axi_awlen",
            "direction": "output",
            "width": LEN_W,
            "descr": "Address write channel burst length.",
        },
        {
            "name": "axi_awsize",
            "direction": "output",
            "width": SIZE_W,
            "descr": "Address write channel burst size. This signal indicates the size of each transfer in the burst.",
        },
        {
            "name": "axi_awburst",
            "direction": "output",
            "width": BURST_W,
            "descr": "Address write channel burst type.",
        },
        {
            "name": "axi_awlock",
            "direction": "output",
            "width": LOCK_W,
            "descr": "Address write channel lock type.",
        },
        {
            "name": "axi_awcache",
            "direction": "output",
            "width": CACHE_W,
            "descr": "Address write channel memory type. Set to 0000 if master output; ignored if slave input.",
        },
        {
            "name": "axi_awqos",
            "direction": "output",
            "width": QOS_W,
            "descr": "Address write channel quality of service.",
        },
        {
            "name": "axi_wlast",
            "direction": "output",
            "width": 1,
            "descr": "Write channel last word flag.",
        },
        {
            "name": "axi_bid",
            "direction": "input",
            "width": ID_W,
            "descr": "Write response channel ID.",
        },
    ]



def get_axi_read_ports():
    axil_read = get_axil_read_ports()

    for port in axil_read:
        port["name"] = port["name"].replace("axil", "axi")
    
    return axil_read + [
        {
            "name": "axi_arid",
            "direction": "output",
            "width": ID_W,
            "descr": "Address read channel ID.",
        },
        {
            "name": "axi_arlen",
            "direction": "output",
            "width": LEN_W,
            "descr": "Address read channel burst length.",
        },
        {
            "name": "axi_arsize",
            "direction": "output",
            "width": SIZE_W,
            "descr": "Address read channel burst size. This signal indicates the size of each transfer in the burst.",
        },
        {
            "name": "axi_arburst",
            "direction": "output",
            "width": BURST_W,
            "descr": "Address read channel burst type.",
        },
        {
            "name": "axi_arlock",
            "direction": "output",
            "width": LOCK_W,
            "descr": "Address read channel lock type.",
        },
        {
            "name": "axi_arcache",
            "direction": "output",
            "width": CACHE_W,
            "descr": "Address read channel memory type. Set to 0000 if master output; ignored if slave input.",
        },
        {
            "name": "axi_arqos",
            "direction": "output",
            "width": QOS_W,
            "descr": "Address read channel quality of service.",
        },
        {
            "name": "axi_rid",
            "direction": "input",
            "width": ID_W,
            "descr": "Read channel ID.",
        },
        {
            "name": "axi_rlast",
            "direction": "input",
            "width": 1,
            "descr": "Read channel last word.",
        },
    ]


def get_axi_ports():
    return (get_axi_read_ports() + get_axi_write_ports())

def get_axis_ports():
    return [
        {
            "name": "axis_tvalid",
            "direction": "output",
            "width": 1,
            "descr": "axis stream valid.",
        },
        {
            "name": "axis_tready",
            "direction": "input",
            "width": 1,
            "descr": "axis stream ready.",
        },
        {
            "name": "axis_tdata",
            "direction": "output",
            "width": DATA_W,
            "descr": "axis stream data.",
        },
        {
            "name": "axis_tlast",
            "direction": "output",
            "width": 1,
            "descr": "axis stream last.",
        },
    ]


#
# APB
#

def get_apb_ports():
    return [
        {
            "name": "apb_addr",
            "direction": "output",
            "width": ADDR_W,
            "descr": "Byte address of the transfer.",
        },
        {
            "name": "apb_sel",
            "direction": "output",
            "width": 1,
            "descr": "Slave select.",
        },
        {
            "name": "apb_enable",
            "direction": "output",
            "width": 1,
            "descr": "Enable. Indicates the number of clock cycles of the transfer.",
        },
        {
            "name": "apb_write",
            "direction": "output",
            "width": 1,
            "descr": "Write. Indicates the direction of the operation.",
        },
        {
            "name": "apb_wdata",
            "direction": "output",
            "width": DATA_W,
            "descr": "Write data.",
        },
        {
            "name": "apb_wstrb",
            "direction": "output",
            "width": int(DATA_W/DATA_SECTION_W),
            "descr": "Write strobe.",
        },
        {
            "name": "apb_rdata",
            "direction": "input",
            "width": DATA_W,
            "descr": "Read data.",
        },
        {
            "name": "apb_ready",
            "direction": "input",
            "width": 1,
            "descr": "Ready. Indicates the end of a transfer.",
        },
    ]

#
# Handle signal direction 
#

# reverse module signal direction
def reverse_direction(direction):
    if direction == "input":
        return "output"
    elif direction == "output":
        return "input"
    else:
        print("ERROR: invalid argument.")
        exit(1)

#testbench signal direction
def get_tbsignal_type(direction):
    if direction == "input":
        return "wire"
    elif direction == "output":
        return "reg"
    else:
        print("ERROR: invalid argument.")
        exit(1)

#get suffix from direction 
def get_suffix(direction):
    if direction == "input" or direction == "reg":
        return "_i"
    elif direction == "output" or direction == "wire":
        return "_o"
    elif direction == "inout":
        return "_io"
    else:
        print("ERROR: invalid argument.")
        exit(1)

# Add a given prefix (in upppercase) to every parameter/macro found in the string
def add_param_prefix(width_str, prefix):
    return re.sub(r"([a-zA-Z_][\w_]*)", prefix.upper() + r"\g<1>", width_str)


#
# Port
#

MULT=1

# Write single port with given direction, bus width, and name to file
def write_port(fout, name, direction, width):
    fout.write(direction + width + name + "," + "\n")

def write_m_port(fout, port_prefix, param_prefix, port_list):
    for i in range(len(port_list)):
        direction = port_list[i]["direction"]
        name = port_prefix + '_' + port_list[i]["name"] + get_suffix(port_list[i]["direction"])
        if MULT == 1:
            width_str = str(port_list[i]["width"])
        else:
            width_str = str("(" + str(MULT) + "*" + port_list[i]["width"] + ")")
        width_str = add_param_prefix(width_str, port_prefix)
        width_str = " [" + width_str + "-1:0] "
        write_port(fout, name, direction, width_str)

def write_s_port(fout, port_prefix, param_prefix, port_list):
    for i in range(len(port_list)):
        direction = reverse_direction(port_list[i]["direction"])
        name = port_prefix + '_' + port_list[i]["name"] + get_suffix(reverse_direction(port_list[i]["direction"]))
        if MULT == 1:
            width_str = str(port_list[i]["width"])
        else:
            width_str = str("(" + str(MULT) + "*" + port_list[i]["width"] + ")")
        width_str = add_param_prefix(width_str, port_prefix)
        width_str = " [" + width_str + "-1:0] "
        write_port(fout, name, direction, width_str)


#
# Portmap
#


# Write single portmap with given portname, wire name, bus start index and size to file
def write_portmap(port, connection_name, width, bus_start, MULT, fout):
    if MULT == 1:
        connection = connection_name
    else:
        bus_select_size = str(MULT) + "*" + width
        if bus_start == 0:
            bus_start_index = str(0)
        else:
            bus_start_index = str(bus_start) + "*" + width
        connection = (
            connection_name + "[" + bus_start_index + "+:" + bus_select_size + "]"
        )
    fout.write("." + port + "(" + connection + "), //" + "\n")

def portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, MULT=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"]
        connection_name = wire_prefix + port_list[i]["name"]
        write_portmap(
            port,
            connection_name,
            port_list[i]["width"],
            bus_start,
            MULT,
            fout,
        )

def m_portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, MULT=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"] + get_suffix(port_list[i]["direction"])
        connection_name = wire_prefix + port_list[i]["name"]
        write_portmap(
            port,
            connection_name,
            port_list[i]["width"],
            bus_start,
            MULT,
            fout,
        )


def s_portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, MULT=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"] + get_suffix(reverse_direction(port_list[i]["direction"]))
        connection_name = wire_prefix + port_list[i]["name"]
        write_portmap(
            port,
            connection_name,
            port_list[i]["width"],
            bus_start,
            MULT,
            fout,
        )


def m_m_portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, MULT=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"] + get_suffix(port_list[i]["direction"])
        connection_name = (
            wire_prefix + port_list[i]["name"] + get_suffix(port_list[i]["direction"])
        )
        write_portmap(
            port,
            connection_name,
            port_list[i]["width"],
            bus_start,
            MULT,
            fout,
        )


def s_s_portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, MULT=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"] + get_suffix(reverse_direction(port_list[i]["direction"]))
        connection_name = (
            wire_prefix + port_list[i]["name"] + get_suffix(reverse_direction(port_list[i]["direction"]))
        )
        write_portmap(
            port,
            connection_name,
            port_list[i]["width"],
            bus_start,
            MULT,
            fout,
        )

#
# Wire
#

# Write wire with given name, bus size, width to file
def write_wire(name, param_prefix, MULT, width, fout):
    width = add_param_prefix(width, param_prefix)
    if MULT == 1:
        bus_width = " [" + width + "-1:0] "
    else:
        bus_width = " [" + str(MULT) + "*" + width + "-1:0] "
    fout.write("wire" + bus_width + name + "; //" + "\n")

# Write reg with given name, bus size, width, initial value to file
def write_reg(name, param_prefix, MULT, width, default, fout):
    width = add_param_prefix(width, param_prefix)
    if MULT == 1:
        bus_width = " [" + width + "-1:0] "
    else:
        bus_width = " [" + str(MULT) + "*" + width + "-1:0] "
    fout.write("reg" + bus_width + name + " = " + default + "; //" + "\n")

# Write tb wire with given tb_signal, prefix, name, bus size, width to file
def write_tb_wire(
    tb_signal,
    prefix,
    name,
    param_prefix,
    MULT,
    width,
    fout,
    default="0",
):
    signal_name = prefix + name + get_suffix(tb_signal)
    if tb_signal == "reg":
        write_reg(
            signal_name, param_prefix, MULT, width, default, fout
        )
    else:
        write_wire(signal_name, param_prefix, MULT, width, fout)


def wire(port_list, prefix, param_prefix, fout, MULT=1):
    for i in range(len(port_list)):
        write_wire(
            prefix + port_list[i]["name"],
            param_prefix,
            MULT,
            port_list[i]["width"],
            fout,
        )


def m_tb_wire(port_list, prefix, param_prefix, fout, MULT=1):
    for i in range(len(port_list)):
        tb_signal = get_tbsignal_type(port_list[i]["direction"])
        write_tb_wire(
            tb_signal,
            prefix,
            port_list[i]["name"],
            param_prefix,
            MULT,
            port_list[i]["width"],
            fout,
        )
    fout.write("\n")


def s_tb_wire(port_list, prefix, param_prefix, fout, MULT=1):
    for i in range(len(port_list)):
        tb_signal = get_tbsignal_type(reverse_direction(port_list[i]["direction"]))
        write_tb_wire(
            tb_signal,
            prefix,
            port_list[i]["name"],
            param_prefix,
            MULT,
            port_list[i]["width"],
            fout,
        )
    fout.write("\n")

def gen_if(name, file_prefix, port_prefix, wire_prefix, ports):
    param_prefix = port_prefix.upper()
    if ports == []:
        eval_str ="get_" + name + "_ports()"
        ports = eval (eval_str)

#    for if_type in range(len(if_types)):
    for i in range(2):
        fout = open(file_prefix +'_' + name + '_' + if_types[i] + ".vs", "w")
        eval_str = "write_" + if_types[i] + "(fout, port_prefix, param_prefix, ports)"
        eval(eval_str)
        fout.close()

#
# Test this module
#

def main():

    global MULT
    global ADDR_W
    global DATA_W

    global ID_W
    global PROT_W
    global RESP_W
    global SIZE_W
    global BURST_W
    global LOCK_W
    global CACHE_W
    global QOS_W
    global LEN_W

    #for if_type in range(len(if_types)):
    for i in range(11,12):
        gen_if(if_names[i], "bla", "di", "da", [])

if __name__ == "__main__":
    main()
