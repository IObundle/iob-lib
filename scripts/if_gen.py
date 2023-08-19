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
    "rom_tdp",
    "ram_sp",
    "ram_tdp",
    "ram_2p",
    "axil_read",
    "axil_write",
    "axil",
    "axi_read",
    "axi_write",
    "axi",
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

DATA_W = 32
ADDR_W = 32

def create_iob():
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
            "width": NDS,
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
            "width": m*DATA_W,
            "descr": "Read data.",
        },
        {
            "name": "iob_ready",
            "direction": "input",
            "width": m,
            "descr": "Interface ready.",
        },
]

def create_clk_rst():
    return [
        {
            "name": "clk",
            "direction": "input",
            "width": 1,
            "descr": "Clock",
        },
        {
            "name": "arst",
            "direction": "input",
            "width": 1,
            "descr": "Asynchronous active-high reset",
        },
    ]

def create_clk_en_rst():
    return [
        {
            "name": "clk",
            "direction": "input",
            "width": 1,
            "descr": "Clock",
        },
        {
            "name": "cke",
            "direction": "input",
            "width": 1,
            "descr": "Enable",
        },
        {
            "name": "arst",
            "direction": "input",
            "width": 1,
            "descr": "Asynchronous active-high reset",
        },
    ]

def create_mem_read(suffix):
    return [
        {
            "name": "clk_"+suffix,
            "direction": "input",
            "width": 1,
            "descr": f"Clock port {suffix}",
        },
        {
            "name": "en_"+suffix,
            "direction": "input",
            "width": 1,
            "descr": f"Enable port {suffix}",
        },
        {
            "name": "addr_a",
            "direction": "input",
            "width": ADDR_W,
            "descr": "Address port {suffix}",
        },
        {
            "name": "rdata_"+suffix,
            "direction": "output",
            "width": DATA_W,
            "descr": "Data port {suffix}",
        },
    ]
    

def create_mem_write(suffix):
    return [
        {
            "name": "clk_"+suffix,
            "direction": "input",
            "width": 1,
            "descr": f"Clock port {suffix}",
        },
        {
            "name": "en_"+suffix,
            "direction": "input",
            "width": 1,
            "descr": f"Enable port {suffix}",
        },
        {
            "name": "addr_a",
            "direction": "input",
            "width": ADDR_W,
            "descr": "Address port {suffix}",
        },
        {
            "name": "wdata_"+suffix,
            "direction": "input",
            "width": DATA_W,
            "descr": "Data port {suffix}",
        },
        {
            "name": "wstrb_"+suffix,
            "direction": "input",
            "width": NDS,
            "descr": "Write strobe port {suffix}",
        },
    ]

def create_rom_sp():
    return list(dict.fromkeys(create_mem_read_port("")))

def create_rom_tdp(port_prefix):
    return list(dict.fromkeys(
        create_mem_read_port("a") +
        create_mem_read_port("b")
    ))

def create_ram_sp():
    return list(dict.fromkeys(
        create_mem_read_port("") +
        create_mem_write_port("")
    ))

def create_ram_tdp():
    return list(dict.fromkeys(
        create_mem_read_port("a") +
        create_mem_read_port("b") +
        create_mem_write_port("a") +
        create_mem_write_port("b")
    ))

def create_ram_2p (port_prefix):
    return list(dict.fromkeys(
        create_mem_write_port("a") +
        create_mem_read_port("b")
    ))
 
#
# AXI4
#
SIZE_W = 3
BURST_W = 2
LOCK_W = 2
CACHE_W = 4
PROT_W = 3
QOS_W = 4
RESP_W = 2

def create_axil_write ():
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
            "width": DATA_W/8,
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

def create_axi_write ():

    axil_write = create_axil_write()

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

def create_axil_read():
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


def create_axi_read():
    axil_read = create_axil_read()

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

def create_axil():
    axil_read = create_axil_read()
    axil_write = create_axil_write()
    return axil_read + axil_write

def create_axi():
    return (create_axi_read() + create_axi_write())

def create_axis():
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

def create_apb():
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
            "width": DATA_W/8,
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
        port_direction = port_list[i]["direction"]
        name = prefix + port_list[i]["name"] + suffix(port_list[i]["direction"])
        if bus_size == 1:
            width = port_list[i]["width"]
        else:
            width = "(" + str(bus_size) + "*" + port_list[i]["width"] + ")"
        width = add_param_prefix(width, param_prefix)
        bus_width = " [" + width + "-1:0] "
        # Write port
        write_port(port_direction, bus_width, name, fout)


def s_port(port_list, prefix, param_prefix, fout, bus_size=1):
    for i in range(len(port_list)):
        port_direction = reverse(port_list[i]["direction"])
        name = prefix + port_list[i]["name"] + suffix(reverse(port_list[i]["direction"]))
        if bus_size == 1:
            width = port_list[i]["width"]
        else:
            width = "(" + str(bus_size) + "*" + port_list[i]["width"] + ")"
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
            port_list[i]["width"],
            bus_start,
            bus_size,
            fout,
        )

def m_portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"] + suffix(port_list[i]["direction"])
        connection_name = wire_prefix + port_list[i]["name"]
        write_portmap(
            port,
            connection_name,
            port_list[i]["width"],
            bus_start,
            bus_size,
            fout,
        )


def s_portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"] + suffix(reverse(port_list[i]["direction"]))
        connection_name = wire_prefix + port_list[i]["name"]
        write_portmap(
            port,
            connection_name,
            port_list[i]["width"],
            bus_start,
            bus_size,
            fout,
        )


def m_m_portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"] + suffix(port_list[i]["direction"])
        connection_name = (
            wire_prefix + port_list[i]["name"] + suffix(port_list[i]["direction"])
        )
        write_portmap(
            port,
            connection_name,
            port_list[i]["width"],
            bus_start,
            bus_size,
            fout,
        )


def s_s_portmap(port_list, port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(port_list)):
        port = port_prefix + port_list[i]["name"] + suffix(reverse(port_list[i]["direction"]))
        connection_name = (
            wire_prefix + port_list[i]["name"] + suffix(reverse(port_list[i]["direction"]))
        )
        write_portmap(
            port,
            connection_name,
            port_list[i]["width"],
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
            port_list[i]["width"],
            fout,
        )


def m_tb_wire(port_list, prefix, param_prefix, fout, bus_size=1):
    for i in range(len(port_list)):
        tb_signal = tbsignal(port_list[i]["direction"])
        write_tb_wire(
            tb_signal,
            prefix,
            port_list[i]["name"],
            param_prefix,
            bus_size,
            port_list[i]["width"],
            fout,
        )
    fout.write("\n")


def s_tb_wire(port_list, prefix, param_prefix, fout, bus_size=1):
    for i in range(len(port_list)):
        tb_signal = tbsignal(reverse(port_list[i]["direction"]))
        write_tb_wire(
            tb_signal,
            prefix,
            port_list[i]["name"],
            param_prefix,
            bus_size,
            port_list[i]["width"],
            fout,
        )
    fout.write("\n")

def write_vs_contents(
        file_object,
        interface,
        port_list,
        port_prefix = "",
        wire_prefix = "",
        bus_size = 1,
        bus_start = 0,
):
    interface_type = get_if_type(interface)

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
    if if_type == interface_types[-1]:
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

    parser.add_argument(
        "--ADDR_W",
        nargs=1,
        help="""Wire prefix.""",
        default=32
    )

    parser.add_argument(
        "--DATA_W",
        nargs=1,
        help="""Data width.""",
        default=32
    )

    parser.add_argument(
        "--ID_W",
        nargs=1,
        help="""ID width.""",
        default=1
    )

    parser.add_argument(
        "--PROT_W",
        nargs=1,
        help="""PROT width.""",
        default=3
    )

    parser.add_argument(
        "--RESP_W",
        nargs=1,
        help="""RESP width.""",
        default=2
    )

    parser.add_argument(
        "--SIZE_W",
        nargs=1,
        help="""SIZE width.""",
        default=3
    )

    parser.add_argument(
        "--BURST_W",
        nargs=1,
        help="""BURST width.""",
        default=2
    )

    parser.add_argument(
        "--LOCK_W",
        nargs=1,
        help="""LOCK width.""",
        default=2
    )

    parser.add_argument(
        "--CACHE_W",
        nargs=1,
        help="""CACHE width.""",
        default=4
    )

    parser.add_argument(
        "--QOS_W",
        nargs=1,
        help="""QOS width.""",
        default=4
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
    
    DATA_W = args.DATA_W
    ADDR_W = args.ADDR_W
    ID_W = args.ID_W
    PROT_W = args.PROT_W
    RESP_W = args.RESP_W
    SIZE_W = args.SIZE_W
    BURST_W = args.BURST_W
    LOCK_W = args.LOCK_W
    CACHE_W = args.CACHE_W
    QOS_W = args.QOS_W
    
    
    # write .vs file
    fout = open(file_prefix + interface + ".vs", "w")

    if_name = get_if_name(interface)

    ports = eval ("create_"+if_name+"()")

    write_vs_contents(fout, interface, ports, port_prefix, wire_prefix)

    fout.close()

if __name__ == "__main__":
    main()
