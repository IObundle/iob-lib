#!/usr/bin/env python3
#
#    ios.py: build Verilog module IO and documentation
#

from latex import write_table
import if_gen
from submodule_utils import (
    get_submodule_directories,
    get_module_io,
    import_setup,
    get_pio_signals,
    if_gen_interface,
    find_suffix_from_list,
)
import importlib.util
import os
import iob_colors


def reverse_port(port_type):
    if port_type == "I":
        return "O"
    else:
        return "I"


# Return full port type string based on given types: "I", "O" and "IO"
# Maps "I", "O" and "IO" to "input", "output" and "inout", respectively.
def get_port_type(port_type):
    if port_type == "I":
        return "input"
    elif port_type == "O":
        return "output"
    else:
        return "inout"


# Find and remove last comma from an IO signal line in a Verilog header file
# It expects file to contain lines formated like:
# input [signal_size-1:0] signal_name,  //Some comment, may contain commas
# Note: file_obj given must have been opened in write+read mode (like "r+" or "w+")
def delete_last_comma(file_obj):
    # Place cursor at the end of the file
    file_obj.read()

    while True:
        # Search for start of line (previous \n) or start of file
        # (It is better than just searching for the comma, because there may be verilog comments in this line with commas that we dont want to remove)
        while file_obj.read(1) != "\n" and file_obj.tell() > 1:
            file_obj.seek(file_obj.tell() - 2)
        # Return if we are at the start of the file (didnt find any comma)
        if file_obj.tell() < 2:
            return
        # Ignore lines starting with Verilog macro
        if file_obj.read(1) != "`":
            file_obj.seek(file_obj.tell() - 1)
            break
        # Move cursor 3 chars back (skip "`", "\n" and previous char)
        file_obj.seek(file_obj.tell() - 3)

    # Search for next comma
    while file_obj.read(1) != ",":
        pass
    file_obj.seek(file_obj.tell() - 1)
    # Delete comma
    file_obj.write(" ")


# Generate io.vs file
# ios: list of tables, each of them containing a list of ports
# Each table is a dictionary with fomat: {'name': '<table name>', 'descr':'<table description>', 'ports': [<list of ports>]}
# Each port is a dictionary with fomat: {'name':"<port name>", 'type':"<port type>", 'n_bits':'<port width>', 'descr':"<port description>"},
def generate_ios_header(ios, top_module, out_dir):

    f_io = open(f"{out_dir}/{top_module}_io.vs", "w+")
    
    for table in ios:
        # If table has 'doc_only' attribute set to True, skip it
        if "doc_only" in table.keys() and table["doc_only"]:
            continue

        # If table has 'ios_table_prefix' attribute set to True, append table name as a prefix to every port
        if "ios_table_prefix" in table.keys():
            ios_table_prefix = table["ios_table_prefix"]
        else:
            ios_table_prefix = False

        if "if_defined" in table.keys():
            f_io.write(f"`ifdef {top_module.upper()}_{table['if_defined']}\n")

        interface = table["name"]
        if_name = if_gen.get_if_name(interface)
        if_type = if_gen.get_if_type(interface)
            
        if if_name:
            
            if_table = if_gen.create_table(if_name)
            if_gen.write_vs_contents(
                if_table,
                if_type,
                f"{if_name+'_' if ios_table_prefix else ''}{if_prefix}",
                "",
                f_io,
            )
        else:
            # Interface is not standard, read ports
            for port in table["ports"]:
                f_io.write(
                    f"{get_port_type(port['type'])} [{port['n_bits']}-1:0] {table['name']+'_' if ios_table_prefix else ''}{port['name']},\n"
                    # f"{get_port_type(port['type'])} [{port['n_bits']}-1:0] {table['name']+'_' if ios_table_prefix else ''}{port['name']}, //{port['descr']}\n"
                )
        if "if_defined" in table.keys():
            f_io.write("`endif\n")

    # Find and remove last comma
    delete_last_comma(f_io)

    f_io.close()


# Generate if.tex file with list TeX tables of IOs
def generate_if_tex(ios, out_dir):
    if_file = open(f"{out_dir}/if.tex", "w")

    if_file.write(
        "The interface signals of the core are described in the following tables.\n"
    )

    for table in ios:
        if_file.write(
            """
\\begin{table}[H]
  \centering
  \\begin{tabularx}{\\textwidth}{|l|l|r|X|}
    
    \hline
    \\rowcolor{iob-green}
    {\\bf Name} & {\\bf Direction} & {\\bf Width} & {\\bf Description}  \\\\ \hline \hline

    \input """
            + table["name"]
            + """_if_tab
 
  \end{tabularx}
  \caption{"""
            + table["descr"].replace("_", "\_")
            + """}
  \label{"""
            + table["name"]
            + """_if_tab:is}
\end{table}
"""
        )

    if_file.write("\clearpage")
    if_file.close()


# Generate TeX tables of IOs
def generate_ios_tex(ios, out_dir):
    # Create if.tex file
    generate_if_tex(ios, out_dir)
 
    for table in ios:
        tex_table = []
        # Check if this table is a standard interface (from if_gen.py)
        if_name = if_gen.get_if_name(table["name"])
        if if_name in if_gen.interface_names:
            # Interface is standard, generate ports
            if_table = if_gen.create_table(if_name)
            
            for port in if_table:
                port_direction = (
                    port["type"]
                    if "m_" in port["name"]
                    else if_gen.reverse(port["type"])
                )  # Reverse port direction if it is a slave interface
                tex_table.append(
                    [
                        (port["name"] + if_gen.suffix(port_direction)).replace(
                            "_", "\_"
                        ),
                        port_direction.replace("`IOB_", "").replace("(", ""),
                        port["width"].replace("_", "\_"),
                        port["description"].replace("_", "\_"),
                    ]
                )
        else:
            # Interface is not standard, read ports
            for port in table["ports"]:
                tex_table.append(
                    [
                        port["name"].replace("_", "\_"),
                        get_port_type(port["type"]),
                        port["n_bits"].replace("_", "\_"),
                        port["descr"].replace("_", "\_"),
                    ]
                )

        write_table(f"{out_dir}/{table['name']}_if", tex_table)


# Returns a string that defines a Verilog mapping. This string can be assigend to a verilog wire/port.
def get_verilog_mapping(map_obj):
    # Check if map_obj is mapped to all bits of a signal (it is a string with signal name)
    if type(map_obj) == str:
        return map_obj

    # Signal is mapped to specific bits of single/multiple wire(s)
    verilog_concat_string = ""
    # Create verilog concatenation of bits of same/different wires
    for map_wire_bit in map_obj:
        # Stop concatenation if we find a bit not mapped. (Every bit after it should not be mapped aswell)
        if not map_wire_bit:
            break
        wire, bit = map_wire_bit
        verilog_concat_string = f"{wire}[{bit}],{verilog_concat_string}"

    verilog_concat_string = "{" + verilog_concat_string
    verilog_concat_string = (
        verilog_concat_string[:-1] + "}"
    )  # Replace last comma by a '}'
    return verilog_concat_string


# peripheral_instance: dictionary describing a peripheral instance. Must have 'name' and 'IO' attributes.
# port_name: name of the port we are mapping
def get_peripheral_port_mapping(peripheral_instance, port_name):
    # If IO dictionary (with mapping) does not exist for this peripheral, use default wire name
    if "io" not in peripheral_instance.__dict__:
        return f"{peripheral_instance.name}_{port_name}"

    assert (
        port_name in peripheral_instance.io
    ), f"{iob_colors.FAIL}Port {port_name} of {peripheral_instance.name} not mapped!{iob_colors.ENDC}"
    # IO mapping dictionary exists, get verilog string for that mapping
    return get_verilog_mapping(peripheral_instance.io[port_name])
