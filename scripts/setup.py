#!/usr/bin/env python3

import sys
import subprocess
from os import path, listdir
import mk_configuration as mk_conf
import mkregs
import ios as ios_lib
import blocks as blocks_lib
from submodule_utils import import_setup
import build_srcs

def getf(obj, name, field):
    return int(obj[next(i for i in range(len(obj)) if obj[i]['name'] == name)][field])

# no_overlap: Optional argument. Selects if read/write addresses should not overlap
def setup( meta_data, confs, ios, regs, blocks, no_overlap=False):

    top = meta_data['name']
    build_dir = meta_data['build_dir']
    # Check if should create build directory for this core/system
    create_build_dir = build_dir==f"../{meta_data['name']}_{meta_data['version']}"

    if create_build_dir:
        subprocess.call(["rsync", "-avz", "--exclude", ".git", "--exclude", "submodules", "--exclude", ".gitmodules", "--exclude", ".github", ".", build_dir])
        subprocess.call(["find", build_dir, "-name", "*_setup*", "-delete"])
        subprocess.call(["cp", "./submodules/LIB/build.mk", f"{build_dir}/Makefile"])
        mk_conf.config_build_mk(confs, meta_data, build_dir)
    
    build_srcs.hw_setup( meta_data )
    build_srcs.python_setup( meta_data )
    #build registers table
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
        mkregs.write_hwheader(reg_table, dirs['build']+'/hardware/src', top)
        mkregs.write_lparam_header(reg_table, dirs['build']+'/hardware/src', top)
        mkregs.write_hwcode(reg_table, dirs['build']+'/hardware/src', top)
    mk_conf.params_vh(confs, top, dirs['build']+'/hardware/src')
    mk_conf.conf_vh(confs, top, dirs['build']+'/hardware/src')

    ios_lib.generate_ios_header(ios, top, dirs['build']+'/hardware/src')

    #
    # Generate sw
    #
    if regs:
        mkregs.write_swheader(reg_table, dirs['build']+'/software/esrc', top)
        mkregs.write_swcode(reg_table, dirs['build']+'/software/esrc', top)
        if path.isdir(dirs['build']+'/software/psrc'): mkregs.write_swheader(reg_table, dirs['build']+'/software/psrc', top)
    mk_conf.conf_h(confs, top, dirs['build']+'/software/esrc')
    if path.isdir(dirs['build']+'/software/psrc'): mk_conf.conf_h(confs, top, dirs['build']+'/software/psrc')

    #
    # Generate TeX
    #
    # Only generate TeX of this core if creating build directory for it
    if path.isdir(dirs['build']+"/document/tsrc") and create_build_dir:
        mk_conf.generate_confs_tex(confs, dirs['build']+"/document/tsrc")
        ios_lib.generate_ios_tex(ios, dirs['build']+"/document/tsrc")
        if regs:
            mkregs.generate_regs_tex(regs, reg_table, build_dir+"/document/tsrc")
        blocks_lib.generate_blocks_tex(blocks, build_dir+"/document/tsrc")

# Setup a submodule in a given build directory (without TeX documentation)
# build_dir: path to build directory
# submodule_dir: root directory of submodule to run setup function
#def setup_submodule(build_dir, submodule_dir):
#    #Import <corename>_setup.py
#    module = import_setup(submodule_dir)
#
#    # Call setup function for this submodule
#    module.main(dirs_override={'build':build_dir}, gen_tex=False, gen_makefile=False)
