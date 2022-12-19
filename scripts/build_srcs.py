import os
from pathlib import Path
import shutil
import if_gen

def import_hw_sources(setup_dir, build_dir, hardware_srcs):
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

def import_Vheaders(Vheaders):
    for vh_name in Vheaders:
        if vh_name in if_gen.interfaces:
            # Interface is standard, generate ports
            if_gen.create_signal_table(vh_name)
            if_gen.write_vh_contents(vh_name, '', '', f_io)


def version_file(module_meta_data, build_dir):
    core_name = module_meta_data['name']
    core_version = module_meta_data['version']

    tex_dir = f"{build_dir}/document/tsrc"
    verilog_dir = f"{build_dir}/hardware/src"
    tex_file = f"{tex_dir}/{core_name}_version.tex"
    with open(tex_file, "w+") as tex_f:
        tex_f.write(core_version)

    vh_file = f"{verilog_dir}/{core_name}_version.vh"
    vh_version_string = '0'
    for c in core_version:
        if(c.isdigit()): 
            vh_version_string += c
    with open(vh_file, "w+") as vh_f:
        vh_f.write(f"`define VERSION {vh_version_string}")