#!/usr/bin/env python3

# (c) 2022-Present IObundle, Lda, all rights reserved
#
# prints version stdout, verilog and latex header files
#

import argparse
import os
from submodule_utils import import_setup



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Get core version from config_setup.mk file")
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "-i", "--info", action="store_true", help="print version to stdout"
    )
    group.add_argument(
        "-t", "--latex", action="store_true", help="generate latex version file"
    )
    group.add_argument(
        "-v", "--verilog", action="store_true", help="generate verilog version file"
    )
    parser.add_argument(
        "path",
        help="""path to directory with *_setup.py file with meta['name'] and meta['version'].""",
    )
    parser.add_argument(
        "-o", help="output file directory"
    )

    args = parser.parse_args()

    # output file directory
    out_dir = '.'
    if args.o:
        out_dir = args.o

    # get core name and version from *_setup.py
    module = import_setup(args.path)
    core_name = module.meta['name']
    core_version = module.meta['version']

    # functionality: [tex file, vh file, stdout print]
    if args.latex:
        tex_file = f"{out_dir}/{core_name}_version.tex"
        with open(tex_file, "w+") as tex_f:
            tex_f.write(core_version)
    elif args.verilog:
        vh_file = f"{out_dir}/{core_name}_version.vh"
        with open(vh_file, "w+") as vh_f:
            vh_f.write(f"`define VERSION {core_version}")
    else:
        print(core_version)
