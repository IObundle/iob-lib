#!/usr/bin/env python3

import sys, os

from submodule_utils import *
import createSystem

#Creates top system based on system_top.vt template 
# setup_dir: root directory of the repository
# submodule_dirs: dictionary with directory of each submodule. Format: {"PERIPHERALCORENAME1":"PATH_TO_DIRECTORY", "PERIPHERALCORENAME2":"PATH_TO_DIRECTORY2"}
# peripherals_list: list of dictionaries each of them describes a peripheral instance
# out_file: path to output file
def create_top_system(setup_dir, submodule_dirs, peripherals_list, out_file):
    # Read template file
    template_file = open(setup_dir+"/hardware/simulation/system_top.vt", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    createSystem.insert_header_files(template_contents, peripherals_list, submodule_dirs)

    # Get port list, parameter list and top module name for each type of peripheral used
    port_list, params_list, top_list = get_peripherals_ports_params_top(peripherals_list, submodule_dirs)

    # Insert wires and connect them to system 
    for instance in peripherals_list:
        pio_signals = get_pio_signals(port_list[instance['type']])

        # Insert system IOs for peripheral
        start_index = find_idx(template_contents, "PWIRES")
        for signal in pio_signals:
            signal_size = replaceByParameterValue(signal['n_bits'],
                          params_list[instance['type']],
                          instance['params'])
            template_contents.insert(start_index, '   {} [{}-1:0] {}_{};\n'.format("wire",
                                                                             signal_size,
                                                                             instance['name'],
                                                                             signal['name']))

        # Connect wires to soc port
        start_index = find_idx(template_contents, "PORTS")
        for signal in pio_signals:
            template_contents.insert(start_index, '               .{signal}({signal}),\n'.format(signal=instance['name']+"_"+signal['name']))

    # Write output file
    output_file = open(out_file, "w")
    output_file.writelines(template_contents)
    output_file.close()

