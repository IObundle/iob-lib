#!/usr/bin/env python3
#
#    ios.py: build Verilog module IO and documentation
#

from latex import write_table
import if_gen
from submodule_utils import get_submodule_directories, get_module_io, import_setup, get_pio_signals, if_gen_interface
import importlib.util
import os
import iob_colors

# List of known interfaces for auto-map
# Any interfaces in this dictionary can by auto mapped by the python scripts
known_map_interfaces =\
{
        'rs232':
            {'rxd':'txd',
             'txd':'rxd',
             'cts':'rts',
             'rts':'cts',
             },
}

def reverse_port(port_type):
    if port_type == "I": return "O"
    else: return "I"

#Given a known interface name, return its mapping
def get_interface_mapping(if_name):
    for interface in known_map_interfaces.items():
        if if_name == interface[0]:
            return interface[1]
    #Interface is was not in 'known_map_interfaces'. Check if_gen.py
    if if_name in if_gen.interfaces:
        if_mapping = {}
        port_list = if_gen_interface(if_name)
        for port in port_list:
            if_mapping[port['name']]=port['name'][:-1]+reverse_port(port['type']).lower()
        return if_mapping

    #Did not find known interface
    assert False, f"{iob_colors.FAIL} Unknown mapping for ports of '{if_name}' interface.{iob_colors.ENDC}"

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
    # Search for start of line (previous \n) or start of file
    # (It is better than just searching for the comma, because there may be verilog comments in this line with commas that we dont want to remove)
    while(file_obj.read(1)!='\n' and file_obj.tell()>1):
        file_obj.seek(file_obj.tell()-2)
    # Search for next comma
    while(file_obj.read(1)!=','):
        pass
    file_obj.seek(file_obj.tell()-1)
    # Delete comma
    file_obj.write(' ')

# Generate io.vh file
# ios: list of tables, each of them containing a list of ports
# Each table is a dictionary with fomat: {'name': '<table name>', 'descr':'<table description>', 'ports': [<list of ports>]}
# Each port is a dictionary with fomat: {'name':"<port name>", 'type':"<port type>", 'n_bits':'<port width>', 'descr':"<port description>"},
# prefix: If should add ios table name as a prefix to every signal in that table
def generate_ios_header(ios, top_module, out_dir, prefix=False):
    f_io = open(f"{out_dir}/{top_module}_io.vh", "w+")

    for table in ios:
        # Check if this table is a standard interface (from if_gen.py)
        if 'if_defined' in table.keys(): f_io.write(f"`ifdef {table['if_defined']}\n")
        if table['name'] in if_gen.interfaces:
            # Interface is standard, generate ports
            if_gen.create_signal_table(table['name'])
            if_gen.write_vh_contents(table['name'], '', table['name']+'_' if prefix else '', f_io)
        else:
            # Interface is not standard, read ports
            for port in table['ports']:
                f_io.write(f"{get_port_type(port['type'])} [{port['n_bits']}-1:0] {table['name']+'_' if prefix else ''}{port['name']}, //{port['descr']}\n")
        if 'if_defined' in table.keys(): f_io.write("`endif\n")

    # Find and remove last comma
    delete_last_comma(f_io)

    f_io.close()

# Generate list of dictionaries with interfaces for each peripheral instance
# Each dictionary is follows the format of a dictionary table in the
# 'ios' list of the <corename>_setup.py
# Example dictionary of a peripheral instance with one port:
#    {'name': 'instance_name', 'descr':'instance description', 'ports': [
#        {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral clock input"}
#    ]}
def get_peripheral_ios(peripherals_list, submodules):
    port_list = {}
    # Get port list for each type of peripheral used
    for instance in peripherals_list:
        # Make sure we have a hw_module for this peripheral type
        assert instance['type'] in submodules["hw_setup"]["modules"], f"{iob_colors.FAIL}peripheral {instance['type']} configured but no corresponding hardware module found!{iob_colors.ENDC}"
        # Only insert ports of this peripheral type if we have not done so before
        if instance['type'] not in port_list:
            # Import <corename>_setup.py module
            module = import_setup(submodules['dirs'][instance['type']])
            # Extract only PIO signals from the peripheral (no reserved/known signals)
            port_list[instance['type']]=get_pio_signals(get_module_io(module.ios))
    
    ios_list = []
    # Append ports of each instance
    for instance in peripherals_list:
        ios_list.append({'name':instance['name'], 'descr':f"{instance['name']} interface signals", 'ports': port_list[instance['type']]})
    return ios_list


# Generate if.tex file with list TeX tables of IOs
def generate_if_tex(ios, out_dir):
    if_file = open(f"{out_dir}/if.tex", "w")

    if_file.write("The interface signals of the core are described in the following tables.\n")

    for table in ios:
        if_file.write(\
'''
\\begin{table}[H]
  \centering
  \\begin{tabularx}{\\textwidth}{|l|l|r|X|}
    
    \hline
    \\rowcolor{iob-green}
    {\\bf Name} & {\\bf Direction} & {\\bf Width} & {\\bf Description}  \\\\ \hline \hline

    \input '''+table['name']+'''_if_tab
 
  \end{tabularx}
  \caption{'''+table['descr'].replace('_','\_')+'''}
  \label{'''+table['name']+'''_if_tab:is}
\end{table}
'''
        )

    if_file.write("\clearpage")
    if_file.close()

# Generate TeX tables of IOs
def generate_ios_tex(ios, out_dir):
    # Create if.tex file
    generate_if_tex(ios,out_dir)

    for table in ios:
        tex_table = []
        # Check if this table is a standard interface (from if_gen.py)
        if table['name'] in if_gen.interfaces:
            # Interface is standard, generate ports
            if_gen.create_signal_table(table['name'])
            for port in if_gen.table:
                port_direction = port['signal'] if 'm_' in port['name'] else if_gen.reverse(port['signal']) # Reverse port direction if it is a slave interface
                tex_table.append([(port['name']+if_gen.suffix(port_direction)).replace('_','\_'),
                                  port_direction.replace('`IOB_','').replace('(',''),
                                  port['width'].replace('_','\_'),
                                  port['description'].replace('_','\_')])
        else:
            # Interface is not standard, read ports
            for port in table['ports']:
                tex_table.append([port['name'].replace('_','\_'),get_port_type(port['type']),port['n_bits'].replace('_','\_'),port['descr'].replace('_','\_')])

        write_table(f"{out_dir}/{table['name']}_if",tex_table)

# Returns a string that defines a Verilog mapping. This string can be assigend to a verilog wire/port.
def get_verilog_mapping(map_obj):
    #Check if map_obj is mapped to all bits of a signal (it is a string with signal name)
    if type(map_obj) == str:
        return map_obj

    #Signal is mapped to specific bits of single/multiple wire(s)
    verilog_concat_string = ""
    #Create verilog concatenation of bits of same/different wires
    for map_wire_bit in map_obj:
        #Stop concatenation if we find a bit not mapped. (Every bit after it should not be mapped aswell)
        if not map_wire_bit: break 
        wire, bit = map_wire_bit
        verilog_concat_string = f"{wire}[{bit}],{verilog_concat_string}"
    #TODO: If mapping is a list of bits...

    verilog_concat_string = "{"+verilog_concat_string
    verilog_concat_string=verilog_concat_string[:-1]+"}" #Replace last comma by a '}'
    return verilog_concat_string

#peripheral_instance: dictionary describing a peripheral instance. Must have 'name' and 'IO' attributes.
#port_name: name of the port we are mapping
def get_peripheral_port_mapping(peripheral_instance, port_name):
    # If IO dictionary (with mapping) does not exist for this peripheral, use default wire name
    if not 'IO' in peripheral_instance:
        return f"{peripheral_instance['name']}_{port_name}"

    assert port_name in peripheral_instance['IO'], f"{iob_colors.FAIL}Port {port_name} of {peripheral_instance['name']} not mapped!{iob_colors.ENDC}"
    # IO mapping dictionary exists, get verilog string for that mapping
    return get_verilog_mapping(peripheral_instance['IO'][port_name])
