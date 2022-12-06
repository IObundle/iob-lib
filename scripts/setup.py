#!/usr/bin/env python3

import sys
from os import path
import param_conf as p_conf
import mkregs
import ios as ios_lib
import blocks as blocks_lib

src_path = './hardware/src/'


def getf(obj, name, field):
    return int(obj[next(i for i in range(len(obj)) if obj[i]['name'] == name)][field])


def setup(top, version, confs, ios, regs, blocks, no_overlap=False):

    #build directory
    build_dir = f"../{top+'_'+version}"
    
    #build registers table
    if regs is not None:
        reg_table = []
        for i_regs in regs:
            reg_table += i_regs['regs']

        mkregs.config = confs
        reg_table = mkregs.compute_addr(reg_table, no_overlap)

        
    #
    # Generate hw
    #
    if regs is not None:
        mkregs.write_hwheader(reg_table, build_dir+'/hardware/src', top)
        mkregs.write_hwcode(reg_table, build_dir+'/hardware/src', top)
    p_conf.params_vh(confs, top, build_dir+'/hardware/src')
    p_conf.conf_vh(confs, top, build_dir+'/hardware/src')

    ios_lib.generate_ios_header(ios, build_dir+'/hardware/src')

    #
    # Generate sw
    #
    if regs is not None:
        mkregs.write_swheader(reg_table, build_dir+'/software/esrc', top)
        mkregs.write_swcode(reg_table, build_dir+'/software/esrc', top)
        if path.isdir(build_dir+'/software/psrc'): mkregs.write_swheader(reg_table, build_dir+'/software/psrc', top)

    #
    # Generate Tex
    #
    if path.isdir(build_dir+"/document/tsrc"):
        p_conf.generate_macros_tex(confs, build_dir+"/document/tsrc")
        p_conf.generate_other_macros_tex(confs, build_dir+"/document/tsrc")
        p_conf.generate_params_tex(confs, build_dir+"/document/tsrc")
        ios_lib.generate_ios_tex(ios, build_dir+"/document/tsrc")
        if regs is not None:
            mkregs.generate_regs_tex(regs, reg_table, build_dir+"/document/tsrc")
        blocks_lib.generate_blocks_tex(blocks, build_dir+"/document/tsrc")
