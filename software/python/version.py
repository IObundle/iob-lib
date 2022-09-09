#!/usr/bin/env python3

# (c) 2022-Present IObundle, Lda, all rights reserved
#
# prints version stdout, verilog and latex header files
#

import argparse
import os
import parse


def parse_makefile_variable(lines, variable):
    search_str = f"{variable}={{value}}\n"
    for line in lines:
        result = parse.search(search_str, line)
        if result:
            return result.named["value"]

    return ""


def parse_mk_file(mk_file):
    with open(mk_file, "r") as mk_f:
        lines = mk_f.readlines()
        core_name = parse_makefile_variable(lines, "NAME")
        core_version = parse_makefile_variable(lines, "VERSION")
        return [core_name, core_version]


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
        help="""path to *.mk file with NAME and VERSION.
            Assume config_setup.mk if path is a directory""",
    )

    args = parser.parse_args()

    # makefile file name
    if os.path.isfile(args.path):
        mk_file = args.path
    else:
        mk_file = f"{args.path}/config_setup.mk"

    # get core name and version from file
    [core_name, core_version] = parse_mk_file(mk_file)
    core_version_str = f"V{int(core_version[:2])}.{int(core_version[2:])}"

    # functionality: [tex file, vh file, stdout print]
    if args.latex:
        tex_file = f"./{core_name}_version.tex"
        with open(tex_file, "w+") as tex_f:
            tex_f.write(core_version_str)
    elif args.verilog:
        vh_file = f"./{core_name}_version.vh"
        with open(vh_file, "w+") as vh_f:
            vh_f.write(f"`define VERSION {core_version}")
    else:
        print(core_version_str)
