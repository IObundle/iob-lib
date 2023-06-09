#!/usr/bin/env python3

import sys
import os
import mk_configuration as mk_conf
import mkregs
import ios as ios_lib
import blocks as blocks_lib
from submodule_utils import import_setup, set_default_submodule_dirs
import build_srcs
import verilog_tools
import shutil

import datetime

from iob_ctls import iob_ctls
from iob_module import iob_module


def getf(obj, name, field):
    return int(obj[next(i for i in range(len(obj)) if obj[i]["name"] == name)][field])


# no_overlap: Optional argument. Selects if read/write register addresses should not overlap
# disable_file_gen: Optional argument. Selects if files should be auto-generated.
def setup(
    python_module, no_overlap=False, disable_file_gen=False
):
    confs = python_module.confs
    ios = python_module.ios
    regs = python_module.regs

    top = python_module.name
    build_dir = python_module.build_dir

    # Auto-add 'VERSION' macro
    confs.append(
        {
            "name": "VERSION",
            "type": "M",
            "val": "16'h" + build_srcs.version_str_to_digits(python_module.version),
            "min": "NA",
            "max": "NA",
            "descr": "Product version. This 16-bit macro uses nibbles to represent decimal numbers using their binary values. The two most significant nibbles represent the integral part of the version, and the two least significant nibbles represent the decimal part. For example V12.34 is represented by 0x1234.",
        }
    )

    #
    # Build registers table
    #
    if regs:
        # Make sure 'general' registers table exists
        general_regs_table = next((i for i in regs if i["name"] == "general"), None)
        if not general_regs_table:
            general_regs_table = {
                "name": "general",
                "descr": "General Registers.",
                "regs": [],
            }
            regs.append(general_regs_table)
        # Auto add 'VERSION' register in 'general' registers table
        general_regs_table["regs"].append(
            {
                "name": "VERSION",
                "type": "R",
                "n_bits": 16,
                "rst_val": build_srcs.version_str_to_digits(python_module.version),
                "addr": -1,
                "log2n_items": 0,
                "autologic": True,
                "descr": "Product version.  This 16-bit register uses nibbles to represent decimal numbers using their binary values. The two most significant nibbles represent the integral part of the version, and the two least significant nibbles represent the decimal part. For example V12.34 is represented by 0x1234.",
            }
        )

        # Create an instance of the mkregs class inside the mkregs module
        # This instance is only used locally, not affecting status of mkregs imported in other functions/modules
        mkregs_obj = mkregs.mkregs()
        mkregs_obj.config = confs
        # Get register table
        reg_table = mkregs_obj.get_reg_table(regs, no_overlap)

        # Auto-add iob_ctls module
        iob_ctls.setup()
        # Auto-add iob_s_port.vh
        iob_module.generate("iob_s_port")
        # Auto-add iob_s_portmap.vh
        iob_module.generate("iob_s_portmap")

    #
    # Setup flows
    #
    build_srcs.flows_setup(python_module)

    # Only auto-generate files if `disable_file_gen` is False
    if not disable_file_gen:
        #
        # Generate hw
        #
        if regs:
            mkregs_obj.write_hwheader(reg_table, build_dir + "/hardware/src", top)
            mkregs_obj.write_lparam_header(
                reg_table, build_dir + "/hardware/simulation/src", top
            )
            mkregs_obj.write_hwcode(reg_table, build_dir + "/hardware/src", top)

        mk_conf.params_vh(confs, top, build_dir + "/hardware/src")

        mk_conf.conf_vh(confs, top, build_dir + "/hardware/src")

        ios_lib.generate_ios_header(ios, top, build_dir + "/hardware/src")

        #
        # Generate sw
        #
        if "emb" in python_module.flows:
            if regs:
                mkregs_obj.write_swheader(
                    reg_table, python_module.build_dir + "/software/src", top
                )
                mkregs_obj.write_swcode(
                    reg_table, python_module.build_dir + "/software/src", top
                )
                mkregs_obj.write_swheader(
                    reg_table, python_module.build_dir + "/software/src", top
                )
            mk_conf.conf_h(confs, top, python_module.build_dir + "/software/src")

        #
        # Generate TeX
        #
        if python_module.is_top_module and 'doc' in python_module.flows:
            mk_conf.generate_confs_tex(
                confs, python_module.build_dir + "/document/tsrc"
            )
            ios_lib.generate_ios_tex(ios, python_module.build_dir + "/document/tsrc")
            if regs:
                mkregs_obj.generate_regs_tex(
                    regs, reg_table, build_dir + "/document/tsrc"
                )
            blocks_lib.generate_blocks_tex(python_module.block_groups, build_dir + "/document/tsrc")

    # Replace Verilog includes by Verilog header file contents
    if python_module.is_top_module:
        verilog_tools.replace_includes(python_module.setup_dir, build_dir)


# Insert header in source files
def insert_header():
    # invoked from the command line as:
    # python3 insert_header.py <header_file> <comment> <file1> <file2> <file3> ...
    # where
    # <header_file> is the name of the header file to be inserted.
    # <comment> is the comment character to be used
    # <file1> <file2> <file3> ... are the files to be processed

    x = datetime.datetime.now()

    module = import_setup(".")

    NAME, VERSION = module.name, module.version

    # header is in the file whose name is given in the second argument
    f = open(sys.argv[2], "r")
    header = f.readlines()
    print(header)
    f.close()

    for filename in sys.argv[4:]:
        f = open(filename, "r+")
        content = f.read()
        f.seek(0, 0)
        for line in header:
            f.write(sys.argv[3] + "  " + f"{line}")
        f.write("\n\n\n" + content)


# If this script is called directly, run function given in first argument
if __name__ == "__main__":
    globals()[sys.argv[1]]()
