import os
import subprocess
from pathlib import Path
import shutil
import if_gen

lib_dir = "./submodules/LIB"

def hw_setup(core_meta_data, core_hw_setup):
    core_name = core_meta_data['name']
    core_version = core_meta_data['version']
    build_dir = core_meta_data['build_dir']
    Vheaders = core_hw_setup['v_headers']
    hardware_srcs = core_hw_setup['hw_modules']

    version_file(core_name, core_version, build_dir)
    if Vheaders!=None: create_Vheaders( build_dir, Vheaders )
    if hardware_srcs!=None: copy_sources( lib_dir, f"{build_dir}/hardware/src", hardware_srcs, '*.v' )

    copy_sources( f"{lib_dir}/hardware/include", f"{build_dir}/hardware/src", [], '*.vh', copy_all = True )
    copy_sources( f"{core_meta_data['core_dir']}/hardware/src", f"{build_dir}/hardware/src", [], '*.v*', copy_all = True )


def sim_setup(core_meta_data, core_sim_setup):
    build_dir = core_meta_data['build_dir']
    sim_srcs  = core_sim_setup['hw_modules']
    sim_srcs.append("iob_tasks.vh")
    copy_sources( lib_dir, f"{build_dir}/hardware/simulation/src", sim_srcs, '*.v*' )
    copy_sources( f"{lib_dir}/hardware/simulation", f"{build_dir}/hardware/simulation", [], '*', copy_all = True )


def fpga_setup(core_meta_data):
    build_dir = core_meta_data['build_dir']
    fpga_dir = "hardware/fpga"

    if not os.path.exists(f"{build_dir}/{fpga_dir}/quartus"): os.makedirs(f"{build_dir}/{fpga_dir}/quartus")
    copy_sources( f"{lib_dir}/{fpga_dir}/quartus", f"{build_dir}/{fpga_dir}/quartus", [], '*', copy_all = True )
    
    if not os.path.exists(f"{build_dir}/{fpga_dir}/vivado"): os.makedirs(f"{build_dir}/{fpga_dir}/vivado")
    copy_sources( f"{lib_dir}/{fpga_dir}/vivado", f"{build_dir}/{fpga_dir}/vivado", [], '*', copy_all = True )

    copy_sources( f"{lib_dir}/{fpga_dir}", f"{build_dir}/{fpga_dir}", [ 'Makefile' ], 'Makefile' )
    subprocess.call(["find", build_dir, "-name", "*.pdf", "-delete"])


def python_setup(core_meta_data):
    build_dir = core_meta_data['build_dir']
    sim_srcs  = [ "sw_defines.py", "hw_defines.py", "console.py", "hex_split.py", "makehex.py" ]
    dest_dir  = f"{build_dir}/scripts"

    if not os.path.exists(dest_dir): os.makedirs(dest_dir)
    copy_sources( lib_dir, dest_dir, sim_srcs, '*.py' )


def copy_sources(lib_dir, dest_dir, hardware_srcs, pattern, copy_all = False):
    if(hardware_srcs != None):
        for path in Path(lib_dir).rglob(pattern):
            verilog_file = path.name
            if (verilog_file in hardware_srcs) or copy_all:
                src_file = path.resolve()
                dest_file = f"{dest_dir}/{verilog_file}"
                if not(os.path.isfile(dest_file)) or (os.stat(src_file).st_mtime > os.stat(dest_file).st_mtime):
                    shutil.copy(src_file, dest_file)


def create_Vheaders(build_dir, Vheaders):
    for vh_name in Vheaders:
        f_out = open (f"{build_dir}/hardware/src/{vh_name}.vh", 'w')
        if vh_name in if_gen.interfaces:
            # Interface is standard, generate ports
            if_gen.create_signal_table(vh_name)
            if_gen.write_vh_contents(vh_name, '', '', f_out)


def version_file(core_name, core_version, build_dir):
    tex_dir = f"{build_dir}/document/tsrc"
    verilog_dir = f"{build_dir}/hardware/src"
    
    if os.path.isdir(tex_dir):
        tex_file = f"{tex_dir}/{core_name}_version.tex"
        with open(tex_file, "w") as tex_f:
            tex_f.write(core_version)

    vh_file = f"{verilog_dir}/{core_name}_version.vh"
    vh_version_string = '0'
    for c in core_version:
        if(c.isdigit()): 
            vh_version_string += c
    with open(vh_file, "w") as vh_f:
        vh_f.write(f"`define VERSION {vh_version_string}")