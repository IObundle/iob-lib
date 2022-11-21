#!/usr/bin/env python3
#
#    ios.py: build Verilog module IO and documentation
#

from verilog2tex import write_table

# Return full port type string based on given types: "I", "O" and "IO"
# Maps "I", "O" and "IO" to "INPUT", "OUTPUT" and "INOUT", respectively.
def get_port_type(port_type):
    if port_type == "I":
        return "INPUT"
    elif port_type == "O":
        return "OUTPUT"
    else:
        return "INOUT"

# Generate io.vh file
# ios: list of tables, each of them containing a list of ports
# Each table is a dictionary with fomat: {'name': '<table name>', 'descr':'<table description>', 'ports': [<list of ports>]}
# Each port is a dictionary with fomat: {'name':"<port name>", 'type':"<port type>", 'n_bits':'<port width>', 'descr':"<port description>"},
def generate_ios_header(ios, out_dir):
    f_io = open(f"{out_dir}/io.vh", "w")

    last_table = False
    last_port = False

    for table_idx, table in enumerate(ios):
        last_table = (len(ios)-table_idx == 1)
        for port_idx, port in enumerate(table['ports']):
            last_port = (len(table['ports'])-port_idx == 1)
            f_io.write(f"`IOB_{get_port_type(port['type'])}({port['name']}, {port['n_bits']}){'' if last_table and last_port else ','} //{port['descr']}\n")

    f_io.close()

# Generate TeX tables of IOs
def generate_ios_tex(ios, out_dir):
    for table in ios:
        tex_table = []
        for port in table['ports']:
            tex_table.append([port['name'].replace('_','\_'),get_port_type(port['type']),port['n_bits'].replace('_','\_'),port['descr']])

        write_table(f"{out_dir}/{table['name']}",tex_table)
