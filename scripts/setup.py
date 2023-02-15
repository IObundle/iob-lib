#!/usr/bin/env python3

import sys
import os
import mk_configuration as mk_conf
import mkregs
import ios as ios_lib
import blocks as blocks_lib
from submodule_utils import import_setup, iob_soc_peripheral_setup, set_default_submodule_dirs
import build_srcs

import periphs_tmp
import createSystem
import createTestbench
import createTopSystem

def getf(obj, name, field):
    return int(obj[next(i for i in range(len(obj)) if obj[i]['name'] == name)][field])

# no_overlap: Optional argument. Selects if read/write addresses should not overlap
# peripheral_ios: Optional argument. Selects if should append peripheral IOs to 'ios' list
# internal_wires: Optional argument. List of extra wires for creste_systemv to create inside this core/system module
def setup( python_module, no_overlap=False, peripheral_ios=True, internal_wires=None):
    confs = python_module.confs
    ios = python_module.ios
    regs = python_module.regs
    blocks = python_module.blocks

    top = python_module.name
    build_dir = python_module.build_dir

    #Auto-add 'VERSION' macro
    confs.append({'name':'VERSION', 'type':'M', 'val':"16'h"+build_srcs.version_str_to_digits(python_module.version), 'min':'NA', 'max':'NA', 'descr':"Product version. This 16-bit macro uses nibbles to represent decimal numbers using their binary values. The two most significant nibbles represent the integral part of the version, and the two least significant nibbles represent the decimal part. For example V12.34 is represented by 0x1234."})

    # Check if should create build directory for this core/system
    #TODO: We need to find another way of checking this. Currently we can not configure another build_dir in *_setup.py because it will cause this to not build the directory!
    create_build_dir = build_dir==f"../{python_module.name}_{python_module.version}"

    set_default_submodule_dirs(python_module)

    #
    # Build directory
    #
    if create_build_dir:
        os.makedirs(build_dir, exist_ok=True)
        mk_conf.config_build_mk(python_module, build_dir)
        mk_conf.config_for_board(top, python_module.flows, build_dir)
        build_srcs.build_dir_setup(python_module)

    #
    # IOb-SoC related functions
    #

    peripherals_list = iob_soc_peripheral_setup(python_module, append_peripheral_ios=peripheral_ios)

    # Build periphs_tmp.h
    if peripherals_list: periphs_tmp.create_periphs_tmp(next(i['val'] for i in confs if i['name'] == 'P'),
                                   peripherals_list, f"{python_module.build_dir}/software/{top}_periphs.h")
    # Try to build iob_soc.v if template is available
    createSystem.create_systemv(python_module.setup_dir, python_module.submodules['dirs'], python_module.name, peripherals_list, os.path.join(python_module.build_dir,f'hardware/src/{top}.v'), internal_wires=internal_wires)
    # Try to build system_tb.v if template is available
    createTestbench.create_system_testbench(python_module.setup_dir, python_module.submodules['dirs'], python_module.name, peripherals_list, os.path.join(python_module.build_dir,f'hardware/simulation/src/{top}_tb.v'))
    # Try to build system_top.v if template is available
    createTopSystem.create_top_system(python_module.setup_dir, python_module.submodules['dirs'], python_module.name, peripherals_list, ios, confs, os.path.join(python_module.build_dir,f'hardware/simulation/src/{top}_top.v'))


    #
    # Build registers table
    #
    if regs:
        # Make sure 'general' registers table exists
        general_regs_table = next((i for i in regs if i['name']=='general'),None)
        if not general_regs_table:
            general_regs_table = {'name': 'general', 'descr':'General Registers.', 'regs': []}
            regs.append(general_regs_table)
        # Auto add 'VERSION' register in 'general' registers table
        general_regs_table['regs'].append({'name':"VERSION", 'type':"R", 'n_bits':16, 'rst_val':build_srcs.version_str_to_digits(python_module.version), 'addr':-1, 'log2n_items':0, 'autologic':True, 'descr':"Product version.  This 16-bit register uses nibbles to represent decimal numbers using their binary values. The two most significant nibbles represent the integral part of the version, and the two least significant nibbles represent the decimal part. For example V12.34 is represented by 0x1234."})

        # Create an instance of the mkregs class inside the mkregs module
        # This instance is only used locally, not affecting status of mkregs imported in other functions/modules
        mkregs_obj = mkregs.mkregs()
        mkregs_obj.config = confs
        # Get register table
        reg_table = mkregs_obj.get_reg_table(regs, no_overlap)


        # Make sure 'hw_setup' dictionary exists
        if 'hw_setup' not in python_module.submodules: python_module.submodules['hw_setup'] = {'headers':[], 'modules':[]}
        # Auto-add iob_ctls module
        python_module.submodules['hw_setup']['modules'].append('iob_ctls')
        # Auto-add iob_s_port.vh
        python_module.submodules['hw_setup']['headers'].append('iob_s_port')
        # Auto-add cpu_iob_s_portmap.vh
        #   [ file_prefix, interface_name, port_prefix, wire_prefix ]
        python_module.submodules['hw_setup']['headers'].append([ 'cpu_', 'iob_s_portmap', '', 'cpu_' ])

        
    #
    # Generate hw
    #
    # Build hardware
    build_srcs.hw_setup( python_module )
    if regs:
        mkregs_obj.write_hwheader(reg_table, build_dir+'/hardware/src', top)
        mkregs_obj.write_lparam_header(reg_table, build_dir+'/hardware/simulation/src', top)
        mkregs_obj.write_hwcode(reg_table, build_dir+'/hardware/src', top)
    mk_conf.params_vh(confs, top, build_dir+'/hardware/src')

    mk_conf.conf_vh(confs, top, build_dir+'/hardware/src')

    ios_lib.generate_ios_header(ios, top, build_dir+'/hardware/src')

    #
    # Generate sw
    #
    if os.path.isdir(python_module.build_dir+'/software'): 
        os.makedirs(python_module.build_dir+'/software/esrc', exist_ok=True)
        os.makedirs(python_module.build_dir+'/software/psrc', exist_ok=True)
        if regs:
            mkregs_obj.write_swheader(reg_table, python_module.build_dir+'/software/esrc', top)
            mkregs_obj.write_swcode(reg_table, python_module.build_dir+'/software/esrc', top)
            mkregs_obj.write_swheader(reg_table, python_module.build_dir+'/software/psrc', top)
        mk_conf.conf_h(confs, top, python_module.build_dir+'/software/esrc')
        mk_conf.conf_h(confs, top, python_module.build_dir+'/software/psrc')

    #
    # Generate TeX
    #
    # Only generate TeX of this core if creating build directory for it
    if os.path.isdir(python_module.build_dir+"/document/tsrc") and create_build_dir:
        mk_conf.generate_confs_tex(confs, python_module.build_dir+"/document/tsrc")
        ios_lib.generate_ios_tex(ios, python_module.build_dir+"/document/tsrc")
        if regs:
            mkregs_obj.generate_regs_tex(regs, reg_table, build_dir+"/document/tsrc")
        blocks_lib.generate_blocks_tex(blocks, build_dir+"/document/tsrc")



#Print build directory of the core/system in the current directory (extracted from *_setup.py)
def get_build_dir():
    module = import_setup(".")
    print(module.build_dir)

#Return white-space separated list of submodules directories of the core/system in the current directory (extracted from *_setup.py)
def get_core_submodules_dirs():
    module = import_setup(".")
    set_default_submodule_dirs(module)
    for key, value in module.submodules['dirs'].items():
        print(f"{key}_DIR={value}", end=" ")

# If this script is called directly, run function given in first argument
if __name__ == '__main__':
    globals()[sys.argv[1]]()
