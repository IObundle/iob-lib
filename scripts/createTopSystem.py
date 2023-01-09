#!/usr/bin/env python3

import sys, os

from submodule_utils import *
import createSystem

#Creates top system based on {top}_top.vt template 
# setup_dir: root directory of the repository
# submodule_dirs: dictionary with directory of each submodule. Format: {"PERIPHERALCORENAME1":"PATH_TO_DIRECTORY", "PERIPHERALCORENAME2":"PATH_TO_DIRECTORY2"}
# peripherals_list: list of dictionaries each of them describes a peripheral instance
# ios: ios dictionary of system
# out_file: path to output file
def create_top_system(setup_dir, submodule_dirs, top, peripherals_list, ios, out_file):
    # Only create testbench if template is available
    if not os.path.isfile(setup_dir+f"/hardware/simulation/{top}_top.vt"): return

    # Read template file
    template_file = open(setup_dir+f"/hardware/simulation/{top}_top.vt", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    createSystem.insert_header_files(template_contents, peripherals_list, submodule_dirs)

    # Insert wires and connect them to system 
    for table in ios:
        pio_signals = get_pio_signals(table['ports'])

        # Insert system IOs for peripheral
        start_index = find_idx(template_contents, "PWIRES")
        for signal in pio_signals:
            template_contents.insert(start_index, '   wire [{}-1:0] {}_{};\n'.format(signal['n_bits'],
                                                                             table['name'],
                                                                             signal['name']))

        # Connect wires to soc port
        start_index = find_idx(template_contents, "PORTS")
        for signal in pio_signals:
            template_contents.insert(start_index, '               .{signal}({signal}),\n'.format(signal=table['name']+"_"+signal['name']))

    # Write output file
    output_file = open(out_file, "w")
    output_file.writelines(template_contents)
    output_file.close()

