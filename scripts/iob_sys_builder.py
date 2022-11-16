#!/usr/bin/env python3

from mkregs import mkregs

def build(pregs, params, top):
    #
    # Generate hw
    #
    args = {'regs': [], 'hwsw': '','TOP':'', 'out_dir':'.'}

    for i in range(len(pregs)):
        args['regs'] += pregs[i]['regs']

    args['hwsw'] = 'HW'
    args['TOP'] = top

    mkregs(args)

    #
    # Generate sw
    #
    args['hwsw'] = 'SW'

    mkregs(args)
