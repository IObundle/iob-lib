#!/usr/bin/env python3

# (c) 2022-Present IObundle, Lda, all rights reserved
#
# prints version stdout, verilog and latex header files
#

import sys

def print_usage():
    usage_str ="""
    Usage: ./version.py [-n] NAME VERSION
      -n: do not output any files
    NAME: core name
    VERSION: core version. Format: 1234 -> V12.34
    """
    
    print(usage_str, file=sys.stderr)
    sys.exit()


if __name__ == "__main__":

    #process command line arguments
    if len(sys.argv) < 3 or len(sys.argv) > 4:
        print_usage()

    no_out_files = 0
    name_idx = 1;

    if len(sys.argv) == 4:
        if sys.argv[1] == '-n':
            no_out_files = 1
            name_idx = 2
        else:
            print_usage()
            
    core_name = sys.argv[name_idx]
    core_version = sys.argv[name_idx+1]

    core_version_str = f"V{int(core_version[:2])}.{int(core_version[2:])}"
    print(core_version_str)

    if no_out_files == 0:
        with open("./{}_version.vh".format(core_name), "w+") as f:
            f.write("`define VERSION {}".format(core_version))
        with open("./{}_version.tex".format(core_name), "w+") as h:
            h.write(core_version_str)
