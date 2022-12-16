import os
from pathlib import Path
import shutil

def import_sources(setup_dir, build_dir, hardware_srcs, software_srcs):
    if(hardware_srcs != None):
        for path in Path(f"{setup_dir}/submodules/LIB").rglob('*.v'):
            verilog_file = path.name
            if verilog_file in hardware_srcs:
                src_file = path.resolve()
                dest_file = f"{build_dir}/hardware/src/{verilog_file}"
                if not(os.path.isfile(dest_file)) or (os.stat(src_file).st_mtime > os.stat(dest_file).st_mtime):
                    shutil.copyfile()

    print('nop')

def build_interface(interface_type):
    print('nop')
