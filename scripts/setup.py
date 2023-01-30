#!/usr/bin/env python3

import sys
from os import path, listdir
import mk_configuration as mk_conf
import mkregs
import ios as ios_lib
import blocks as blocks_lib
from submodule_utils import import_setup

src_path = './hardware/src/'

def getf(obj, name, field):
    return int(obj[next(i for i in range(len(obj)) if obj[i]['name'] == name)][field])

# no_overlap: Optional argument. Selects if read/write addresses should not overlap
# build_dir: Optional argument. Location of build directory. If left as 'None', name is auto generated.
# gen_tex: Optional argument. Selects if TeX documentation should be generated.
def setup( meta_data, confs, ios, regs, blocks, no_overlap=False, build_dir=None, gen_tex=True ):

    top = meta_data['name']
    version = meta_data['version']
    #build directory
    if not build_dir:
        build_dir = f"../{top}_{version}"
    mk_conf.config_build_mk(confs, meta_data, build_dir)
    
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
        mkregs.write_hwheader(reg_table, build_dir+'/hardware/src', top)
        mkregs.write_lparam_header(reg_table, build_dir+'/hardware/simulation/src', top)
        mkregs.write_hwcode(reg_table, build_dir+'/hardware/src', top)
    mk_conf.params_vh(confs, top, build_dir+'/hardware/src')
    mk_conf.conf_vh(confs, top, build_dir+'/hardware/src')

    ios_lib.generate_ios_header(ios, top, build_dir+'/hardware/src')

    #
    # Generate sw
    #
    if regs:
        mkregs.write_swheader(reg_table, build_dir+'/software/esrc', top)
        mkregs.write_swcode(reg_table, build_dir+'/software/esrc', top)
        if path.isdir(build_dir+'/software/psrc'): mkregs.write_swheader(reg_table, build_dir+'/software/psrc', top)
    mk_conf.conf_h(confs, top, build_dir+'/software/esrc')
    if path.isdir(build_dir+'/software/psrc'): mk_conf.conf_h(confs, top, build_dir+'/software/psrc')

    #
    # Generate Tex
    #
    if path.isdir(build_dir+"/document/tsrc") and gen_tex:
        mk_conf.generate_confs_tex(confs, build_dir+"/document/tsrc")
        ios_lib.generate_ios_tex(ios, build_dir+"/document/tsrc")
        if regs:
            mkregs.generate_regs_tex(regs, reg_table, build_dir+"/document/tsrc")
        blocks_lib.generate_blocks_tex(blocks, build_dir+"/document/tsrc")

# Setup a submodule in a given build directory (without TeX documentation)
# build_dir: path to build directory
# submodule_dir: root directory of submodule to run setup function
def setup_submodule(build_dir, submodule_dir):
    #Import <corename>_setup.py
    module = import_setup(submodule_dir)

    # Call setup function for this submodule
    module.main(build_dir=build_dir, gen_tex=False)
