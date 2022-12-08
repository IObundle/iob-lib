#!/usr/bin/env python3

import sys, os

from submodule_utils import *
import createSystem

#Creates testbench based on system_tb.vt template 
# root_dir: root directory of the repository
# peripherals_list: list of dictionaries each of them describes a peripheral instance
# out_file: path to output file
def create_system_testbench(root_dir, peripherals_list, out_file):
    submodule_dirs = get_submodule_directories(root_dir)

    # Read template file
    template_file = open(root_dir+"/hardware/simulation/system_tb.vt", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    # Insert header files
    createSystem.insert_header_files(template_contents, peripherals_list, submodule_dirs)

    # Write system_tb.v
    output_file = open(out_file, "w")
    output_file.writelines(template_contents)
    output_file.close()
