#!/usr/bin/env python3

import sys
import param_conf as p_conf
from mkregs import mkregs
from verilog2tex import verilog2tex

src_path = './hardware/src/'

def setup(top, version, params, ios, regs, blocks):

    #build directory
    build_dir = f"../{top+'_'+version}";
    
    #build registers table
    table = []
    for i in range(len(regs)):
        table += regs[i]['regs'];

        
    #
    # Generate hw
    #

    mkregs(table, 'HW', top, build_dir+'/hardware/src')
    p_conf.params_vh(params, top, build_dir+'/hardware/src')
    #p_conf.conf_vh(params, top, build_dir+'/hardware/src')

    #
    # Generate sw
    #
    #mkregs(table, 'SW', top, '.')

    #
    # Generate Tex
    #
    #for i in range(len(vh)):
    #    vh[i] = src_path + vh[i]

    #for i in range(len(v)):
    #    v[i] = src_path + v[i]

    #v.insert(0, src_path+top+'.v')

    #verilog2tex(regs, v[0], vh, v)
