#!/usr/bin/env python3

# Generates hardware header from list of macros
#
#   See "Usage" below
#

import sys
import pathlib


def usage():
    print("Usage: ./hw_defines.py [output] [defmacro] {DEFINES}")
    print("\t[output]: output filename")
    print("\t[defmacro]: define macro prefix")
    print("\t{DEFINES}: list of defines with the format -DMACRO=VALUE")
    quit()


if __name__ == "__main__":
    if len(sys.argv) < 3:
        usage()

    fout_name = sys.argv[1]
    defmacro = sys.argv[2]
    define_list = sys.argv[3:]
    fname = pathlib.Path(fout_name).stem.upper()

    with open(fout_name, "w") as fout:
        fout.write(f"`ifndef VH_{fname}_VH\n")
        fout.write(f"`define VH_{fname}_VH\n\n")
        for define in define_list:
            if defmacro in define:
                # remove [defmacro] prefix
                define = define.split(defmacro, 1)[1]
                if "=" in define:
                    macro, value = define.split("=", 1)
                    fout.write(f"`define {macro} ({value})\n")
                else:
                    macro = define
                    fout.write(f"`define {macro}\n")
        fout.write(f"\n`endif // VH_{fname}_VH")
