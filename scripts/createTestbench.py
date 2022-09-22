#!/usr/bin/env python3
#Creates system_tb.v based on system_core_tb.v template 

import sys, os

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *
import createSystem

def create_system_testbench(root_dir, peripherals_str, file_path):
    # Get peripherals, directories and signals
    instances_amount, _ = get_peripherals(peripherals_str)
    submodule_directories = get_submodule_directories(root_dir)

    # Read template file
    template_file = open(root_dir+"/hardware/simulation/system_tb.vt", "r")
    template_contents = template_file.readlines() 
    template_file.close()

    # Insert header files
    createSystem.insert_header_files(template_contents, root_dir)

    # Write system_tb.v
    output_file = open(file_path, "w")
    output_file.writelines(template_contents)
    output_file.close()


if __name__ == "__main__":
    # Parse arguments
    if len(sys.argv)<4:
        print("Usage: {} <root_dir> <peripherals> <path of file to be created>\n".format(sys.argv[0]))
        exit(-1)
    create_system_testbench(sys.argv[1], sys.argv[2], sys.argv[3]) 
