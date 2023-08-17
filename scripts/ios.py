#!/usr/bin/env python3
#
#    ios.py: build Verilog module IO and documentation
#

from latex import write_table
import if_gen
import submodule_utils
import importlib.util
import os
import iob_colors


def reverse_port(port_type):
    if port_type == "input":
        return "output"
    else:
        return "input"

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


def write_ports(ios, top_module, out_dir):
    
    f_io = open(f"{out_dir}/{top_module}_io.vs", "w+")
    
    for table in ios:
        # Open ifdef if conditional interface
        if "if_defined" in table.keys():
            f_io.write(f"`ifdef {top_module.upper()}_{table['if_defined']}\n")

        if_gen.write_vs_contents(
            file_object=f_io,
            sig_table = table["ports"],
            interface_type = if_gen.get_if_type(table["name"]),
            port_prefix = table["port_prefix"] if "port_prefix" in table.keys() else "",
            wire_prefix = table["wire_prefix"] if "wire_prefix" in table.keys() else "",
        )

        # Close ifdef if conditional interface
        if "if_defined" in table.keys():
            f_io.write("`endif\n")

    # Find and remove last comma
    delete_last_comma(f_io)

    f_io.close()


def generate_ports(ios):

    for table in ios:
        # If table has 'doc_only' attribute set to True, skip it
        if "doc_only" in table.keys() and table["doc_only"]:
            continue

        if_name = if_gen.get_if_name(table["name"])

        if if_name:
            table["ports"] = if_gen.create_table(if_name)

    return ios

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
                        port["n_bits"].replace("_", "\_"),
                        port["descr"].replace("_", "\_"),
                    ]
                )
        else:
            # Interface is not standard, read ports
            for port in table["ports"]:
                tex_table.append(
                    [
                        port["name"].replace("_", "\_"),
                        port["type"],
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
