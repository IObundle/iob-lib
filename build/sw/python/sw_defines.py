#!/usr/bin/env python3

# Generates software header from list of macros
#
#   See "Usage" below
#

import sys
import parse
import pathlib


def usage():
    print("Usage: ./sw_defines.py [output] {DEFINES}")
    print("\t[output]: output filename")
    print("\t{DEFINES}: list of defines with the format MACRO=VALUE")
    quit()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        usage()

    fout_name = sys.argv[1]
    define_list = sys.argv[2:]
    fname = pathlib.Path(fout_name).stem.upper()

    with open(fout_name, "w") as fout:
        fout.write(f"#ifndef H_{fname}_H\n")
        fout.write(f"#define H_{fname}_H\n\n")
        for define in define_list:
            try:
                parsed_def = parse.search("{macro}={value}", define).named
                fout.write(f'#define {parsed_def["macro"]} ({parsed_def["value"]})\n')
            except AttributeError:
                continue
        fout.write(f"\n#endif // H_{fname}_H")
