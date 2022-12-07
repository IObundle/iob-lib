#!/usr/bin/env python3
#
#    ios.py: build Verilog module IO and documentation
#

from latex import write_table
import if_gen
from submodule_utils import get_peripherals, get_submodule_directories
import importlib.util
import os

# Return full port type string based on given types: "I", "O" and "IO"
# Maps "I", "O" and "IO" to "input", "outpuT" and "inout", respectively.
def get_port_type(port_type):
    if port_type == "I":
        return "input"
    elif port_type == "O":
        return "output"
    else:
        return "inout"

# Generate io.vh file
# ios: list of tables, each of them containing a list of ports
# Each table is a dictionary with fomat: {'name': '<table name>', 'descr':'<table description>', 'ports': [<list of ports>]}
# Each port is a dictionary with fomat: {'name':"<port name>", 'type':"<port type>", 'n_bits':'<port width>', 'descr':"<port description>"},
def generate_ios_header(ios, top_module, out_dir):
    f_io = open(f"{out_dir}/{top_module}_io.vh", "w+")

    for table in ios:
        # Check if this table is a standard interface (from if_gen.py)
        if table['name'] in if_gen.interfaces:
            # Interface is standard, generate ports
            if_gen.create_signal_table(table['name'])
            if_gen.write_vh_contents(table['name'], '', '', f_io)
        else:
            # Interface is not standard, read ports
            for port in table['ports']:
                f_io.write(f"{get_port_type(port['type'])} [{port['n_bits']}-1:0] {port['name']}, //{port['descr']}\n")

    # Find and remove last comma
    while(f_io.read(1)!=',' and f_io.tell()>1):
        f_io.seek(f_io.tell()-2)
    f_io.seek(f_io.tell()-1)
    if f_io.read(1)==',':
        f_io.seek(f_io.tell()-1)
        f_io.write(' ')

    f_io.close()

# Generate list of dictionaries with interfaces for each peripheral instance
# Each dictionary is follows the format of a dictionary table in the
# 'ios' list of the <corename>_setup.py
# Example dictionary of a peripheral instance with one port:
#    {'name': 'instance_name', 'descr':'instance description', 'ports': [
#        {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral clock input"}
#    ]}
def get_peripheral_ios(peripherals_str, root_dir):
    instances_amount, _ = get_peripherals(peripherals_str)
    submodule_dirs = get_submodule_directories(root_dir)
    ios_list = []
    for corename in instances_amount:
        #Find <corename>_setup.py file
        for x in os.listdir(submodule_dirs[corename]):
            if x.endswith("_setup.py"):
                filename = x
                break
        #Import <corename>_setup.py
        spec = importlib.util.spec_from_file_location(corename, submodule_dirs[corename]+"/"+filename)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        #Get all IO signals for this peripheral
        port_list = []
        for table in module.ios:
            port_list.extend(table['ports'])
        #Append each instance IOs to the ios_list
        for i in range(instances_amount[corename]):
            instance_port_list = port_list.copy()
            #Add instance prefix to every port of this instance
            for port in instance_port_list:
                port['name'] = corename+str(i)+"_"+port['name']
            #Append IOs of this instance
            ios_list.append({'name':corename+str(i), 'descr':f'{corename+str(i)} interface signals', 'ports': instance_port_list})
        #Unload module
        #del sys.modules[corename]; del module
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
  \\begin{tabular}{|l|l|r|p{10.5cm}|}
    
    \hline
    \\rowcolor{iob-green}
    {\\bf Name} & {\\bf Direction} & {\\bf Width} & {\\bf Description}  \\\\ \hline \hline

    \input '''+table['name']+'''_if_tab
 
  \end{tabular}
  \caption{'''+table['descr']+'''}
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
