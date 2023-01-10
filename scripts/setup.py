#!/usr/bin/env python3

import sys
import os
import mk_configuration as mk_conf
import mkregs
import ios as ios_lib
import blocks as blocks_lib
from submodule_utils import import_setup
import build_srcs
import iob_soc

import periphs_tmp
import createSystem
import createTestbench
import createTopSystem

def getf(obj, name, field):
    return int(obj[next(i for i in range(len(obj)) if obj[i]['name'] == name)][field])

# no_overlap: Optional argument. Selects if read/write addresses should not overlap
# ios_prefix: Optional argument. Selects if IO signals should be prefixed by their table name. Useful when multiple tables have signals with the same name.
# peripheral_ios: Optional argument. Selects if should append peripheral IOs to 'ios' list
# internal_wires: Optional argument. List of extra wires for creste_systemv to create inside this core/system module
def setup( meta_data, confs, ios, regs, blocks, no_overlap=False, ios_prefix=False, peripheral_ios=True, internal_wires=None):

    top = meta_data['name']
    build_dir = meta_data['build_dir']
    # Check if should create build directory for this core/system
    create_build_dir = build_dir==f"../{meta_data['name']}_{meta_data['version']}"

    build_srcs.set_default_submodule_dirs(meta_data)
    build_srcs.add_setup_lambdas(meta_data,confs=confs,ios=ios,regs=regs,blocks=blocks)

    #
    # Build directory
    #
    if create_build_dir:
        build_srcs.build_dir_setup(meta_data)
        mk_conf.config_build_mk(confs, meta_data, build_dir)
    
    #
    # IOb-SoC related functions
    #

    # Get peripherals list from 'peripherals' table in blocks list
    peripherals_list = iob_soc.get_peripherals_list(blocks)
    # Get peripheral related macros
    if peripherals_list: iob_soc.get_peripheral_macros(confs, peripherals_list)
    # Append peripherals IO 
    if peripherals_list and peripheral_ios: ios.extend(ios_lib.get_peripheral_ios(peripherals_list, meta_data['submodules']))
    # Build periphs_tmp.h
    if peripherals_list: periphs_tmp.create_periphs_tmp(next(i['val'] for i in confs if i['name'] == 'P'),
                                   peripherals_list, f"{meta_data['build_dir']}/software/periphs.h")
    # Try to build iob_soc.v if template is available
    createSystem.create_systemv(meta_data['setup_dir'], meta_data['submodules']['dirs'], meta_data['name'], peripherals_list, os.path.join(meta_data['build_dir'],f'hardware/src/{top}.v'), internal_wires=internal_wires)
    # Try to build system_tb.v if template is available
    createTestbench.create_system_testbench(meta_data['setup_dir'], meta_data['submodules']['dirs'], meta_data['name'], peripherals_list, os.path.join(meta_data['build_dir'],f'hardware/simulation/src/{top}_tb.v'))
    # Try to build system_top.v if template is available
    createTopSystem.create_top_system(meta_data['setup_dir'], meta_data['submodules']['dirs'], meta_data['name'], peripherals_list, ios, os.path.join(meta_data['build_dir'],f'hardware/simulation/src/{top}_top.v'))


    #
    # Build registers table
    #
    if regs:
        reg_table = []
        for i_regs in regs:
            reg_table += i_regs['regs']

        # Create an instance of the mkregs class inside the mkregs module
        # This instance is only used locally, not affecting status of mkregs imported in other functions/modules
        mkregs_obj = mkregs.mkregs()
        mkregs_obj.config = confs
        reg_table = mkregs_obj.compute_addr(reg_table, no_overlap)

        
    #
    # Generate hw
    #
    build_srcs.hw_setup( meta_data )
    if regs:
        mkregs_obj.write_hwheader(reg_table, meta_data['build_dir']+'/hardware/src', top)
        mkregs_obj.write_lparam_header(reg_table, meta_data['build_dir']+'/hardware/src', top)
        mkregs_obj.write_hwcode(reg_table, meta_data['build_dir']+'/hardware/src', top)
    mk_conf.params_vh(confs, top, meta_data['build_dir']+'/hardware/src')
    mk_conf.conf_vh(confs, top, meta_data['build_dir']+'/hardware/src')

    ios_lib.generate_ios_header(ios, top, meta_data['build_dir']+'/hardware/src',prefix=ios_prefix)

    #
    # Generate sw
    #
    if regs:
        mkregs_obj.write_swheader(reg_table, meta_data['build_dir']+'/software/esrc', top)
        mkregs_obj.write_swcode(reg_table, meta_data['build_dir']+'/software/esrc', top)
        if os.path.isdir(meta_data['setup_dir']+'/software/psrc'): mkregs_obj.write_swheader(reg_table, meta_data['build_dir']+'/software/psrc', top)
    mk_conf.conf_h(confs, top, meta_data['build_dir']+'/software/esrc')
    if os.path.isdir(meta_data['setup_dir']+'/software/psrc'): mk_conf.conf_h(confs, top, meta_data['build_dir']+'/software/psrc')

    #
    # Generate TeX
    #
    # Only generate TeX of this core if creating build directory for it
    if os.path.isdir(meta_data['build_dir']+"/document/tsrc") and create_build_dir:
        mk_conf.generate_confs_tex(confs, meta_data['build_dir']+"/document/tsrc")
        ios_lib.generate_ios_tex(ios, meta_data['build_dir']+"/document/tsrc")
        if regs:
            mkregs_obj.generate_regs_tex(regs, reg_table, build_dir+"/document/tsrc")
        blocks_lib.generate_blocks_tex(blocks, build_dir+"/document/tsrc")



#Return name of the core/system in the current directory (extracted from *_setup.py)
def get_core_name():
    module = import_setup(".")
    print(module.meta['name'])

#Return version of the core/system in the current directory (extracted from *_setup.py)
def get_core_version():
    module = import_setup(".")
    print(module.meta['version'])

#Return version of the core/system in the current directory (extracted from *_setup.py)
def get_core_flows():
    module = import_setup(".")
    print(module.meta['flows'])

#Return white-space separated list of submodules directories of the core/system in the current directory (extracted from *_setup.py)
def get_core_submodules_dirs():
    module = import_setup(".")
    build_srcs.set_default_submodule_dirs(module.meta)
    for key, value in module.meta['submodules']['dirs'].items():
        print(f"{key}_DIR={value}", end=" ")

# If this script is called directly, run function given in first argument
if __name__ == '__main__':
    globals()[sys.argv[1]]()
