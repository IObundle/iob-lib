import os, sys
import subprocess
from pathlib import Path
import shutil
import if_gen
import iob_colors

lib_dir = "./submodules/LIB"

# core_meta_data: dictionary with meta data of core
# setup_dir: setup directory of core
# build_dir: build directory
# lib_srcs: 
def hw_setup(core_meta_data, setup_dir, build_dir, lib_srcs):
    core_name = core_meta_data['name']
    core_version = core_meta_data['version']

    core_hw_setup = lib_srcs['hw_setup']
    Vheaders = core_hw_setup['v_headers']
    hardware_srcs = core_hw_setup['hw_modules']

    if "sim" in core_meta_data['flows']: 
        core_sim_setup = lib_srcs['sim_setup']
        sim_srcs = core_sim_setup['hw_modules']
        sim_Vheaders = core_sim_setup['v_headers']

    version_file(core_name, core_version, build_dir)

    for hardware_src in ((hardware_srcs + sim_srcs) if ("sim" in core_meta_data['flows']) else hardware_srcs):
        if hardware_src in lib_modules.keys():
            Vheaders += lib_modules[hardware_src]['v_headers']
            hardware_srcs += lib_modules[hardware_src]['hw_modules']
            if "sim" in core_meta_data['flows']:
                sim_srcs += lib_modules[hardware_src]['sim_modules']
                sim_Vheaders += lib_modules[hardware_src]['sim_v_headers']

    if Vheaders!=None: create_Vheaders( f"{build_dir}/hardware/src", Vheaders )
    if hardware_srcs!=None: copy_sources( lib_dir, f"{build_dir}/hardware/src", hardware_srcs, '*.v' )

    copy_sources( f"{lib_dir}/hardware/include", f"{build_dir}/hardware/src", [], '*.vh', copy_all = True )
    copy_sources( f"{setup_dir}/hardware/src", f"{build_dir}/hardware/src", [], '*.v*', copy_all = True )

    if "sim" in core_meta_data['flows']: sim_setup( build_dir, sim_srcs, sim_Vheaders )
    #if "fpga" in core_meta_data['flows']: fpga_setup( build_dir )


def sim_setup(build_dir, sim_srcs, sim_Vheaders):
    sim_dir = "hardware/simulation"

    sim_srcs.append("iob_tasks.vh")

    if (sim_Vheaders!=[ ]): create_Vheaders( f"{build_dir}/{sim_dir}/src", sim_Vheaders )
    copy_sources( lib_dir, f"{build_dir}/{sim_dir}/src", sim_srcs, '*.v*' )
    copy_sources( f"{lib_dir}/{sim_dir}", f"{build_dir}/{sim_dir}", [], '*', copy_all = True )


def fpga_setup(build_dir):
    fpga_dir = "hardware/fpga"

    if not os.path.exists(f"{build_dir}/{fpga_dir}/quartus"): os.makedirs(f"{build_dir}/{fpga_dir}/quartus")
    copy_sources( f"{lib_dir}/{fpga_dir}/quartus", f"{build_dir}/{fpga_dir}/quartus", [], '*', copy_all = True )
    
    if not os.path.exists(f"{build_dir}/{fpga_dir}/vivado"): os.makedirs(f"{build_dir}/{fpga_dir}/vivado")
    copy_sources( f"{lib_dir}/{fpga_dir}/vivado", f"{build_dir}/{fpga_dir}/vivado", [], '*', copy_all = True )

    copy_sources( f"{lib_dir}/{fpga_dir}", f"{build_dir}/{fpga_dir}", [ 'Makefile' ], 'Makefile' )
    subprocess.call(["find", build_dir, "-name", "*.pdf", "-delete"])


def python_setup(build_dir):
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
                if os.path.isfile(src_file) and (not(os.path.isfile(dest_file)) or (os.stat(src_file).st_mtime > os.stat(dest_file).st_mtime)):
                    shutil.copy(src_file, dest_file)
                elif not(os.path.isfile(src_file)): print(f"{iob_colors.WARNING}{src_file} is not a file.{iob_colors.ENDC}")


def create_Vheaders(dest_dir, Vheaders):
    for vh_name in Vheaders:
        if (type(vh_name) is str) and (vh_name in if_gen.interfaces):
            if 'iob_' in vh_name: file_prefix = ''
            else: file_prefix = 'iob_'
            f_out = open (f"{dest_dir}/{file_prefix}{vh_name}.vh", 'w')
            if_gen.create_signal_table(vh_name)
            if_gen.write_vh_contents(vh_name, '', '', f_out)
        elif (type(vh_name) is list) and (vh_name[1] in if_gen.interfaces):
            f_out = open (f"{dest_dir}/{vh_name[0]}{vh_name[1]}.vh", 'w')
            if_gen.create_signal_table(vh_name[1])
            if_gen.write_vh_contents(vh_name[1], vh_name[2], vh_name[3], f_out)
        else: 
            sys.exit(f"{iob_colors.FAIL} {vh_name} is not an available header.{iob_colors.ENDC}")


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

lib_modules = {
    'apb2iob':{
        'v_headers'    : [ 'iob_wire', 'iob_s_portmap', 'iob_m_portmap', 'iob_m_port', 'apb_s_s_portmap', 'apb_s_port' ],
        'hw_modules'   : [ 'apb2iob.v' ],
        'sim_v_headers': [  ],
        'sim_modules'  : [  ]
    },
    'iob2apb':{
        'v_headers'    : [ 'iob_s_port', 'iob_s_s_portmap', 'apb_m_port', 'apb_m_portmap', 'apb_wire' ],
        'hw_modules'   : [ 'iob2apb.v', 'iob_reg_a.v' ],
        'sim_v_headers': [ 'iob_m_tb_wire' ],
        'sim_modules'  : [  ]
    },
    'iob2axis':{
        'v_headers'    : [  ],
        'hw_modules'   : [  ],
        'sim_v_headers': [ ['stream_', 'iob_wire', 'stream_', ''] ],
        'sim_modules'  : [ 'iob2axis.v' ]
    },
    'iob_fifo_async':{
        'v_headers'    : [  ],
        'hw_modules'   : [ 'iob_fifo_async.v', 'iob_ram_t2p_asym.v', 'iob_gray_counter.v', 'iob_gray2bin.v' ],
        'sim_v_headers': [  ],
        'sim_modules'  : [  ]
    },
    'iob_fifo_sync':{
        'v_headers'    : [  ],
        'hw_modules'   : [ 'iob_fifo_sync.v', 'iob_reg_ae.v', 'iob_reg_are.v', 'iob_counter.v', 'iob_ram_2p_asym.v', 'iob_ram_2p.v' ],
        'sim_v_headers': [  ],
        'sim_modules'  : [  ]
    },
    'iob_modcnt_n':{
        'v_headers'    : [  ],
        'hw_modules'   : [ 'iob_modcnt_n.v', 'iob_counter_n.v' ],
        'sim_v_headers': [  ],
        'sim_modules'  : [  ]
    },
    'iob_modcnt_ld':{
        'v_headers'    : [  ],
        'hw_modules'   : [ 'iob_modcnt_ld.v', 'iob_counter_ld.v' ],
        'sim_v_headers': [  ],
        'sim_modules'  : [  ]
    },
}
