#!/usr/bin/env python3

from mkregs import mkregs
from verilog2tex import verilog2tex

src_path = './hardware/src/'

def build(pregs, params, top, vh, v):
    #
    # Generate hw
    #
    regs = []
    for i in range(len(pregs)):
        regs += pregs[i]['regs']

    mkregs(regs, 'HW', top, '.')

    #
    # Generate sw
    #
    mkregs(regs, 'SW', top, '.')

    #
    # Generate Tex
    #
    for i in range(len(vh)):
        vh[i] = src_path + vh[i]

    for i in range(len(v)):
        v[i] = src_path + v[i]

    v.insert(0, src_path+top+'.v')

    verilog2tex(pregs, v[0], vh, v)
