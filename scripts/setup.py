#!/usr/bin/env python3

import sys
from os import path, listdir
import param_conf as p_conf
import mkregs
import ios as ios_lib
import blocks as blocks_lib
import importlib

src_path = './hardware/src/'

# no_overlap: Optional argument. Selects if read/write addresses should not overlap
# build_dir: Optional argument. Location of build directory. If left as 'None', name is auto generated.
# gen_tex: Optional argument. Selects if TeX documentation should be generated.
def setup(top, version, confs, ios, regs, blocks, no_overlap=False, build_dir=None, gen_tex=True):

    #build directory
    if not build_dir:
        build_dir = f"../{top+'_'+version}"
    
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
        mkregs.write_hwcode(reg_table, build_dir+'/hardware/src', top)
    p_conf.params_vh(confs, top, build_dir+'/hardware/src')
    p_conf.conf_vh(confs, top, build_dir+'/hardware/src')

    ios_lib.generate_ios_header(ios, top, build_dir+'/hardware/src')

    #
    # Generate sw
    #
    if regs:
        mkregs.write_swheader(reg_table, build_dir+'/software/esrc', top)
        mkregs.write_swcode(reg_table, build_dir+'/software/esrc', top)
        if path.isdir(build_dir+'/software/psrc'): mkregs.write_swheader(reg_table, build_dir+'/software/psrc', top)

    #
    # Generate Tex
    #
    if path.isdir(build_dir+"/document/tsrc") and gen_tex:
        p_conf.generate_macros_tex(confs, build_dir+"/document/tsrc")
        p_conf.generate_other_macros_tex(confs, build_dir+"/document/tsrc")
        p_conf.generate_params_tex(confs, top, build_dir+"/document/tsrc")
        ios_lib.generate_ios_tex(ios, build_dir+"/document/tsrc")
        if regs:
            mkregs.generate_regs_tex(regs, reg_table, build_dir+"/document/tsrc")
        blocks_lib.generate_blocks_tex(blocks, build_dir+"/document/tsrc")

# Setup a submodule in a given build directory (without TeX documentation)
# build_dir: path to build directory
# submodule_dir: root directory of submodule to run setup function
def setup_submodule(build_dir, submodule_dir):
    #Find <corename>_setup.py file
    for x in listdir(submodule_dir):
        if x.endswith("_setup.py"):
            filename = x
            break
    #Import <corename>_setup.py
    spec = importlib.util.spec_from_file_location("submodule_module", submodule_dir+"/"+filename)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Call setup function for this submodule
    setup(module.top, module.version, module.confs, module.ios, module.regs if hasattr(module,'regs') else None, module.blocks, build_dir=build_dir, gen_tex=False)
