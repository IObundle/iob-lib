import os, sys, re
import subprocess
from pathlib import Path
import shutil
import importlib
# IObundle scripts imported:
import if_gen
#import ios # Not in use
from submodule_utils import import_setup
import iob_colors

lib_dir = "submodules/LIB"

# build_dir_setup should only be called by the main core. Therefor, executed only one time.
def build_dir_setup(core_meta_data):
    build_dir = core_meta_data['build_dir']
    setup_dir = core_meta_data['setup_dir']
    core_flows = core_meta_data['flows']
    # Setup HARDWARE directories :
    os.makedirs(f"{build_dir}/hardware/src")
    if "sim" in core_flows: 
        sim_setup( core_meta_data )
    if "fpga" in core_flows: 
        fpga_setup( core_meta_data )
    if "lint" in core_flows: 
        lint_setup( core_meta_data )
    # Setup SOFTWARE directories :
    if ("emb" in core_flows) or ("pc-emul" in core_flows):
        sw_setup( core_meta_data )
    # Setup DOC directories :
    if "doc" in core_flows: 
        doc_setup( core_meta_data )
    # Setup DELIVERY directories :
    # (WIP)
    # Copy generic MAKEFILE
    shutil.copyfile(f"{lib_dir}/build.mk", f"{build_dir}/Makefile")


def hw_setup(core_meta_data):
    core_name = core_meta_data['name']
    core_version = core_meta_data['version']
    build_dir = core_meta_data['build_dir']
    setup_dir = core_meta_data['setup_dir']

    core_hw_setup = core_meta_data['submodules']['hw_setup']
    Vheaders = core_hw_setup['v_headers']
    hardware_srcs = core_hw_setup['hw_modules']

    # create module's *_version.vh Verilog Header
    version_file(core_name, core_version, build_dir)

    module_dependency_setup(hardware_srcs, Vheaders, build_dir, core_meta_data['submodules']['dirs'])

    if Vheaders!=None: create_Vheaders( f"{build_dir}/hardware/src", Vheaders )
    if hardware_srcs!=None: copy_files( lib_dir, f"{build_dir}/hardware/src", hardware_srcs, '*.v' )

    copy_files( f"{lib_dir}/hardware/include", f"{build_dir}/hardware/src", [], '*.vh', copy_all = True )
    copy_files( f"{setup_dir}/hardware/src", f"{build_dir}/hardware/src", [], '*.v*', copy_all = True )

def sim_setup( core_meta_data ):
    build_dir = core_meta_data['build_dir']
    setup_dir = core_meta_data['setup_dir']
    submodule_dirs = core_meta_data['submodules']['dirs']
    sim_dir = "hardware/simulation"
    sim_srcs = ["iob_tasks.vh"]
    Vheaders = []
    
    if 'sim_setup' in core_meta_data['submodules'].keys():
        sim_setup = core_meta_data['submodules']['sim_setup']
        Vheaders.extend(sim_setup['v_headers'])
        sim_srcs.extend(sim_setup['hw_modules'])

    shutil.copytree(f"{setup_dir}/hardware/simulation", f"{build_dir}/hardware/simulation")
    module_dependency_setup(sim_srcs, Vheaders, build_dir, submodule_dirs) 
    # Sim modules probably shouldn't be dealt with similarly to hardware module

    if (Vheaders!=[ ]): create_Vheaders( f"{build_dir}/{sim_dir}/src", Vheaders )
    copy_files( lib_dir, f"{build_dir}/{sim_dir}/src", sim_srcs, '*.v*' )
    copy_files( f"{lib_dir}/{sim_dir}", f"{build_dir}/{sim_dir}", copy_all = True )

# Currently not used because it is not needed
def fpga_setup(core_meta_data):
    build_dir = core_meta_data['build_dir']
    setup_dir = core_meta_data['setup_dir']
    fpga_dir = "hardware/fpga"

    shutil.copytree(f"{setup_dir}/{fpga_dir}", f"{build_dir}/{fpga_dir}")
    for file in Path(f"{lib_dir}/{fpga_dir}").rglob('*'):
        src_file = file.as_posix()
        dest_file = re.sub(lib_dir, build_dir, src_file)
        if os.path.isfile(src_file): shutil.copyfile(f"{src_file}", f"{dest_file}")
    subprocess.call(["find", build_dir, "-name", "*.pdf", "-delete"])

def lint_setup(core_meta_data):
    build_dir = core_meta_data['build_dir']
    core_name = core_meta_data['name']
    lint_dir = "hardware/lint"

    os.mkdir(f"{build_dir}/{lint_dir}")
    files = Path(f"{lib_dir}/{lint_dir}").glob('*')
    for file in files:
        with open(f"{lib_dir}/{lint_dir}/{file}", "r") as sources:
            lines = sources.readlines()
        with open(f"{build_dir}/{lint_dir}/{file}", "w") as sources:
            for line in lines:
                sources.write(re.sub(r'IOB_CORE_NAME', core_name, line))


def sw_setup(core_meta_data):
    core_flows = core_meta_data['flows']
    build_dir = core_meta_data['build_dir']
    setup_dir = core_meta_data['setup_dir']

    shutil.copytree(f"{setup_dir}/software", f"{build_dir}/software", ignore=shutil.ignore_patterns('*_setup*'))
    if "emb" in core_flows and not(os.path.exists(f"{setup_dir}/software/embedded")): os.mkdir(f"{setup_dir}/software/embedded")
    #aux = copy_files(f"{lib_dir}/software/src", f"{build_dir}/software/esrc", copy_all = True)
    #print(aux)
    if "pc-emul" in core_flows: copy_files(f"{lib_dir}/software/pc-emul", f"{build_dir}/software/pc-emul", copy_all = True)
    if "emb" in core_flows: copy_files(f"{lib_dir}/software/embedded", f"{build_dir}/software/embedded", copy_all = True)
    if ('sw_setup' and 'dirs') in core_meta_data['submodules'].keys():
        core_sw_setup = core_meta_data['submodules']['sw_setup']
        submodule_dirs = core_meta_data['submodules']['dirs']
        for module in core_sw_setup['sw_modules']:
            if module in submodule_dirs.keys():
                copy_files(f"{submodule_dirs[module]}/software/src", f"{build_dir}/software/esrc", copy_all = True)
                copy_files(f"{submodule_dirs[module]}/software/src", f"{build_dir}/software/psrc", copy_all = True)
                if "pc-emul" in core_flows: copy_files(f"{submodule_dirs[module]}/software/psrc", f"{build_dir}/software/psrc", copy_all = True)
                if "emb" in core_flows: copy_files(f"{submodule_dirs[module]}/software/esrc", f"{build_dir}/software/esrc", copy_all = True)
            else: sys.exit(f"{iob_colors.FAIL}{module} not in submodule directories.{iob_colors.ENDC}")
    else: print(f"{iob_colors.INFO}No modules are used or the module directories where not correctly defined.{iob_colors.ENDC}")

    python_setup(build_dir)
    shutil.copy(f"{lib_dir}/scripts/console.mk", f"{build_dir}/console.mk")

def python_setup(build_dir):
    sim_srcs  = [ "sw_defines.py", "hw_defines.py", "console.py", "hex_split.py", "makehex.py" ]
    dest_dir  = f"{build_dir}/scripts"
    if not os.path.exists(dest_dir): os.mkdir(dest_dir)
    copy_files( lib_dir, dest_dir, sim_srcs, '*.py' )


def doc_setup( meta_core_data ):
    core_flows = meta_core_data['flows']
    build_dir = meta_core_data['build_dir']
    setup_dir = meta_core_data['setup_dir']

    shutil.copytree(f"{setup_dir}/document", f"{build_dir}/document")  


# Setup a submodule in a given build directory
# build_dir: path to build directory
# submodule_dir: root directory of submodule to run setup function
def submodule_setup(build_dir, submodule_dir):
    #Check if submodule has *_setup.py file
    for fname in os.listdir('.'):
        if fname.endswith('_setup.py'):
            iob_submodule_setup(build_dir, submodule_dir)
            return

    #Did not find *_setup.py file, copy sources only
    shutil.copytree(f"{submodule_dir}/hardware/src", f"{build_dir}/hardware/src")

# Setup a submodule in a given build directory using its *_setup.py file
# build_dir: destination build directory
# submodule_dir: root directory of submodule to run setup function
def iob_submodule_setup(build_dir, submodule_dir):
    #Import <corename>_setup.py
    module = import_setup(submodule_dir)
    module.meta['flows'] = ''
    module.meta['build_dir'] = build_dir
    module.meta['setup_dir'] = submodule_dir
    # Call setup function for this submodule
    module.main()

#hardware_srcs: list that may contain 3 types of entries:
#                   - submodule: This entry defines a submodule to include (may contain *_setup.py or just a set of sources).
#                   - python include: This entry defines a python module that contains a list of other hardware modules/headers.
#                   - verilog source:  This entry defines either a verilog header (.vh) or verilog source (.v) file to include.
def module_dependency_setup(hardware_srcs, Vheaders, build_dir, submodule_dirs):
    # Remove all non *.v and *.vh entries from hardware_srcs
    # Do this by setting up submodules and including hardware modules/headers
    while(True):
        # Handle each entry, skipping .v and .vh entries
        for hardware_src in hardware_srcs:
            # Entry is a 'submodule'
            if hardware_src in submodule_dirs:
                submodule_setup(build_dir, submodule_dirs[hardware_src])
                hardware_srcs.remove(hardware_src)
                break
            # Entry is a 'python include'
            elif not(hardware_src.endswith(".v") or hardware_src.endswith(".vh")):
                lib_module_setup(Vheaders, hardware_srcs, hardware_src)
                hardware_srcs.remove(hardware_src)
                break
        # Did not find any non .v or .vh entry
        else: break

# Include Vheaders and hardware_srcs from given python module (module_name)
def lib_module_setup(Vheaders, hardware_srcs, module_name):
    for lib_module_path in Path(lib_dir).rglob(f"{module_name}.py"):
        spec = importlib.util.spec_from_file_location("lib_module", lib_module_path)
        lib_module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(lib_module)
        Vheaders.extend(lib_module.v_headers)
        hardware_srcs.extend(lib_module.hw_modules)
        break
    else: sys.exit(f"{iob_colors.FAIL} {module_name} is not a LIB module.{iob_colors.ENDC}")


def copy_files(src_dir, dest_dir, sources = [], pattern = "*", copy_all = False):
    files_copied = []
    if(sources != []) or copy_all:
        for path in Path(src_dir).rglob(pattern):
            file = path.name
            if (file in sources) or copy_all:
                src_file = path.resolve()
                dest_file = f"{dest_dir}/{file}"
                if os.path.isfile(src_file) and (not(os.path.isfile(dest_file)) or (os.stat(src_file).st_mtime > os.stat(dest_file).st_mtime)):
                    shutil.copy(src_file, dest_file)
                    files_copied.append(file)
                elif not(os.path.isfile(src_file)): print(f"{iob_colors.WARNING}{src_file} is not a file.{iob_colors.ENDC}")
    else: print(f"{iob_colors.WARNING}'copy_files' function did nothing.{iob_colors.ENDC}")
    return files_copied


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


# Adds and fills 'dirs' dictionary inside 'submodules' dicionary of given core/system 'meta_data'
def set_default_submodule_dirs(meta_data):
    #Make sure 'dirs' dictionary exists
    if 'dirs' not in meta_data['submodules']:
        meta_data['submodules']['dirs'] = {}

    if os.path.isdir(f"{meta_data['setup_dir']}/submodules"):
        # Add default path for every submodule without a path
        for submodule in os.listdir(f"{meta_data['setup_dir']}/submodules"):
            if submodule not in meta_data['submodules']['dirs']:
                meta_data['submodules']['dirs'].update({submodule:f"{meta_data['setup_dir']}/submodules/{submodule}"})

    #Make sure 'LIB' path exists
    if 'LIB' not in meta_data['submodules']['dirs']:
        meta_data['submodules']['dirs']['LIB'] = lib_dir


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
