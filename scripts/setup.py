#!/usr/bin/env python3

import sys
import subprocess
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
def setup( meta_data, confs, ios, regs, blocks, no_overlap=False, ios_prefix=False):

    top = meta_data['name']
    build_dir = meta_data['build_dir']
    # Check if should create build directory for this core/system
    create_build_dir = build_dir==f"../{meta_data['name']}_{meta_data['version']}"

    build_srcs.set_default_submodule_dirs(meta_data)
    build_srcs.lib_dir = meta_data['submodules']['dirs']['LIB']

    #
    # Build directory
    #
    if create_build_dir:
        subprocess.call(["rsync", "-avz", "--exclude", ".git", "--exclude", "submodules", "--exclude", ".gitmodules", "--exclude", ".github", ".", build_dir])
        subprocess.call(["find", build_dir, "-name", "*_setup*", "-delete"])
        subprocess.call(["cp", f"{meta_data['submodules']['dirs']['LIB']}/build.mk", f"{build_dir}/Makefile"])
        mk_conf.config_build_mk(confs, meta_data, build_dir)

    
    #
    # IOb-SoC related functions
    #

    # Get peripherals list from 'peripherals' table in blocks list
    peripherals_list = iob_soc.get_peripherals_list(blocks)
    # Get peripheral related macros
    if peripherals_list: iob_soc.get_peripheral_macros(confs, peripherals_list)
    # Append peripherals IO 
    if peripherals_list: ios.extend(ios_lib.get_peripheral_ios(peripherals_list, meta_data['submodules']))
    # Build periphs_tmp.h
    if peripherals_list: periphs_tmp.create_periphs_tmp(next(i['val'] for i in confs if i['name'] == 'P'),
                                   peripherals_list, f"{meta_data['build_dir']}/software/periphs.h")
    # Try to build iob_soc.v if template is available
    createSystem.create_systemv(meta_data['setup_dir'], meta_data['submodules']['dirs'], meta_data['name'], peripherals_list, os.path.join(meta_data['build_dir'],'hardware/src/iob_soc.v'))
    # Try to build system_tb.v if template is available
    createTestbench.create_system_testbench(meta_data['setup_dir'], meta_data['submodules']['dirs'], meta_data['name'], peripherals_list, os.path.join(meta_data['build_dir'],'hardware/simulation/src/system_tb.v'))
    # Try to build system_top.v if template is available
    createTopSystem.create_top_system(meta_data['setup_dir'], meta_data['submodules']['dirs'], meta_data['name'], peripherals_list, os.path.join(meta_data['build_dir'],'hardware/simulation/src/system_top.v'))


    #
    # Setup functions
    #
    build_srcs.hw_setup( meta_data )
    build_srcs.python_setup( meta_data['build_dir'])


    #
    # Build registers table
    #
    if regs:
        reg_table = []
        for i_regs in regs:
            reg_table += i_regs['regs']

        mkregs.config = confs
        reg_table = mkregs.compute_addr(reg_table, no_overlap)

        
    #
    # Generate hw
    #
    if regs:
        mkregs.write_hwheader(reg_table, meta_data['build_dir']+'/hardware/src', top)
        mkregs.write_lparam_header(reg_table, meta_data['build_dir']+'/hardware/src', top)
        mkregs.write_hwcode(reg_table, meta_data['build_dir']+'/hardware/src', top)
    mk_conf.params_vh(confs, top, meta_data['build_dir']+'/hardware/src')
    mk_conf.conf_vh(confs, top, meta_data['build_dir']+'/hardware/src')

    ios_lib.generate_ios_header(ios, top, meta_data['build_dir']+'/hardware/src',prefix=ios_prefix)

    #
    # Generate sw
    #
    if regs:
        mkregs.write_swheader(reg_table, meta_data['build_dir']+'/software/esrc', top)
        mkregs.write_swcode(reg_table, meta_data['build_dir']+'/software/esrc', top)
        if os.path.isdir(meta_data['build_dir']+'/software/psrc'): mkregs.write_swheader(reg_table, meta_data['build_dir']+'/software/psrc', top)
    mk_conf.conf_h(confs, top, meta_data['build_dir']+'/software/esrc')
    if os.path.isdir(meta_data['build_dir']+'/software/psrc'): mk_conf.conf_h(confs, top, meta_data['build_dir']+'/software/psrc')

    #
    # Generate TeX
    #
    # Only generate TeX of this core if creating build directory for it
    if os.path.isdir(meta_data['build_dir']+"/document/tsrc") and create_build_dir:
        mk_conf.generate_confs_tex(confs, meta_data['build_dir']+"/document/tsrc")
        ios_lib.generate_ios_tex(ios, meta_data['build_dir']+"/document/tsrc")
        if regs:
            mkregs.generate_regs_tex(regs, reg_table, build_dir+"/document/tsrc")
        blocks_lib.generate_blocks_tex(blocks, build_dir+"/document/tsrc")
