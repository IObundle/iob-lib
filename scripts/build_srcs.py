import os, sys, re
import subprocess
from pathlib import Path
import shutil
import importlib.util

# IObundle scripts imported:
import if_gen
from submodule_utils import import_setup, set_default_submodule_dirs
import iob_colors
import inspect
import mk_configuration as mk_conf

LIB_DIR = "submodules/LIB"


# Copy a file if destination does not exist
def copy_without_override(src, dst):
    if not os.path.isfile(dst):
        shutil.copy2(src, dst)


# build_dir_setup should only be called by the main core. Therefore, executed only one time.
def build_dir_setup(python_module):
    build_dir = python_module.build_dir
    setup_dir = python_module.setup_dir
    core_flows = python_module.flows
    # Setup HARDWARE directories :
    os.makedirs(f"{build_dir}/hardware/src", exist_ok=True)

    # Setup simulation
    sim_setup(python_module)

    # Setup fpga
    fpga_setup(python_module)

    if "lint" in core_flows:
        lint_setup(python_module)
    if "syn" in core_flows:
        syn_setup(python_module)

    # Setup software
    sw_setup(python_module)

    # Setup DOC directories :
    doc_setup(python_module)
    # Setup DELIVERY directories :
    # (WIP)
    # Copy generic MAKEFILE
    shutil.copyfile(f"{LIB_DIR}/build.mk", f"{build_dir}/Makefile")


def hw_setup(python_module):
    core_name = python_module.name
    core_version = python_module.version
    if "previous_version" in vars(python_module):
        core_previous_version = python_module.previous_version
    else:
        core_previous_version = core_version
    build_dir = python_module.build_dir
    setup_dir = python_module.setup_dir

    # Make sure 'hw_setup' dictionary exists
    if "hw_setup" not in python_module.submodules:
        python_module.submodules["hw_setup"] = {"headers": [], "modules": []}

    core_hw_setup = python_module.submodules["hw_setup"]
    # This list may contain .vh files or strings or tuples describing interfaces to be generated with_if_gen.py
    Vheaders = core_hw_setup["headers"]
    # This list may contain .v files, LIB python_modules, or functions to be called.
    hardware_srcs = core_hw_setup["modules"]

    set_default_submodule_dirs(
        python_module
    )  # Make sure that dictionary submodules dirs exists (set default directory for non existing ones)
    submodule_dirs = python_module.submodules["dirs"]

    # create module's *_version.vh Verilog Header
    version_file(core_name, core_version, core_previous_version, build_dir)

    # Copy Setup hw files (all .v and .sdc files under LIB/hardware/src)
    copy_files(
        f"{setup_dir}/hardware/src",
        f"{build_dir}/hardware/src",
        [],
        "*.v*",
        copy_all=True,
    )
    copy_files(
        f"{setup_dir}/hardware/src",
        f"{build_dir}/hardware/src",
        [],
        "*.sdc*",
        copy_all=True,
    )

    # Setup any hw submodules by calling the 'main()' function from their *_setup.py module
    module_dependency_setup(
        hardware_srcs, Vheaders, build_dir, submodule_dirs, lib_dir=LIB_DIR
    )

    # Create if_gen interfaces and copy every .vh file from LIB in the Vheaders list.
    if Vheaders:
        create_if_gen_headers(f"{build_dir}/hardware/src", Vheaders)
        copy_files(LIB_DIR, f"{build_dir}/hardware/src", Vheaders, "*.vh")

    if hardware_srcs:
        # Copy every .v file from LIB that is in the hw_srcs list
        copy_files(LIB_DIR, f"{build_dir}/hardware/src", hardware_srcs, "*.v*")
        # Remove duplicate files for fpga/src and simulation/src dir if they already exist in hardware/src
        for file in hardware_srcs:
            if os.path.isfile(f"{build_dir}/hardware/simulation/src/{file}"):
                os.remove(f"{build_dir}/hardware/simulation/src/{file}")
            if os.path.isfile(f"{build_dir}/hardware/fpga/src/{file}"):
                os.remove(f"{build_dir}/hardware/fpga/src/{file}")

    # Copy LIB header files (all .vh files under LIB/hardware/src)
    copy_files(
        f"{LIB_DIR}/hardware/modules",
        f"{build_dir}/hardware/src",
        [],
        "*.vh",
        copy_all=True,
    )


# Setup simulation related files/modules
# module: python module representing a *_setup.py file of the root directory of the core/system.
def sim_setup(python_module):
    core_flows = python_module.flows
    build_dir = python_module.build_dir
    setup_dir = python_module.setup_dir

    # Make sure 'sim_setup' dictionary exists
    if "sim_setup" not in python_module.submodules:
        python_module.submodules["sim_setup"] = {"headers": [], "modules": []}

    sim_setup = python_module.submodules["sim_setup"]
    Vheaders = sim_setup["headers"]
    sim_srcs = sim_setup["modules"]

    set_default_submodule_dirs(
        python_module
    )  # Make sure that dictionary submodules dirs exists (set default directory for non existing ones)
    submodule_dirs = python_module.submodules["dirs"]
    sim_dir = "hardware/simulation"

    # append this core hw flows to config_build
    if "sim" not in core_flows:
        mk_conf.append_flows_config_build_mk(core_flows, ["sim"], build_dir)

    if "sim" in core_flows:
        shutil.copytree(
            f"{setup_dir}/{sim_dir}",
            f"{build_dir}/{sim_dir}",
            dirs_exist_ok=True,
            copy_function=copy_without_override,
            ignore=shutil.ignore_patterns("*_setup*"),
        )

    # Add functions to the sim_srcs. These functions call setup modules for simulation setup (sim_setup.py)
    add_setup_functions(python_module, "sim_setup", setup_module=python_module)
    # Setup any sim submodules by calling the 'sim_setup()' function from their *_setup.py module
    module_dependency_setup(
        sim_srcs,
        Vheaders,
        build_dir,
        submodule_dirs,
        function_2_call="setup.build_srcs.sim_setup",
        lib_dir=LIB_DIR,
    )

    # Create if_gen interfaces and copy every .vh file from LIB in the Vheaders list.
    if Vheaders:
        create_if_gen_headers(f"{build_dir}/{sim_dir}/src", Vheaders)
        copy_files(LIB_DIR, f"{build_dir}/{sim_dir}/src", Vheaders, "*.vh")
    # Copy every .v file from LIB that is in the sim_srcs list
    if sim_srcs:
        copy_files(LIB_DIR, f"{build_dir}/{sim_dir}/src", sim_srcs, "*.v*")

    # Copy LIB sim files
    if "sim" in core_flows:
        shutil.copytree(
            f"{LIB_DIR}/{sim_dir}",
            f"{build_dir}/{sim_dir}",
            dirs_exist_ok=True,
            copy_function=copy_without_override,
            ignore=shutil.ignore_patterns("*.pdf"),
        )


# Currently not used because it is not needed
def fpga_setup(python_module):
    core_flows = python_module.flows
    build_dir = python_module.build_dir
    setup_dir = python_module.setup_dir

    # Make sure 'fpga_setup' dictionary exists
    if "fpga_setup" not in python_module.submodules:
        python_module.submodules["fpga_setup"] = {"headers": [], "modules": []}

    fpga_setup = python_module.submodules["fpga_setup"]
    Vheaders = fpga_setup["headers"]
    fpga_srcs = fpga_setup["modules"]

    set_default_submodule_dirs(
        python_module
    )  # Make sure that dictionary submodules dirs exists (set default directory for non existing ones)
    submodule_dirs = python_module.submodules["dirs"]
    fpga_dir = "hardware/fpga"

    # append this core hw flows to config_build
    mk_conf.append_flows_config_build_mk(core_flows, ["fpga"], build_dir)

    if "fpga" in core_flows:
        shutil.copytree(
            f"{setup_dir}/{fpga_dir}",
            f"{build_dir}/{fpga_dir}",
            dirs_exist_ok=True,
            copy_function=copy_without_override,
            ignore=shutil.ignore_patterns("*_setup*"),
        )

    # Add functions to the fpga_srcs. These functions call setup modules for fpga setup (fpga_setup.py)
    add_setup_functions(python_module, "fpga_setup", setup_module=python_module)
    # Setup any fpga submodules by calling the 'fpga_setup()' function from their *_setup.py module
    module_dependency_setup(
        fpga_srcs,
        Vheaders,
        build_dir,
        submodule_dirs,
        function_2_call="setup.build_srcs.fpga_setup",
        lib_dir=LIB_DIR,
    )

    # Create if_gen interfaces and copy every .vh file from LIB in the Vheaders list.
    if Vheaders:
        create_if_gen_headers(f"{build_dir}/{fpga_dir}/src", Vheaders)
        copy_files(LIB_DIR, f"{build_dir}/{fpga_dir}/src", Vheaders, "*.vh")
    # Copy every .v file from LIB that is in the fpga_srcs list
    if fpga_srcs:
        copy_files(LIB_DIR, f"{build_dir}/{fpga_dir}/src", fpga_srcs, "*.v*")

    # Copy LIB fpga files
    if "fpga" in core_flows:
        shutil.copytree(
            f"{LIB_DIR}/{fpga_dir}",
            f"{build_dir}/{fpga_dir}",
            dirs_exist_ok=True,
            copy_function=copy_without_override,
            ignore=shutil.ignore_patterns("*.pdf"),
        )


def lint_setup(python_module):
    build_dir = python_module.build_dir
    core_name = python_module.name
    setup_dir = python_module.setup_dir
    lint_dir = "hardware/lint"

    os.mkdir(f"{build_dir}/{lint_dir}")
    files = Path(f"{LIB_DIR}/{lint_dir}").glob("*")
    for file in files:
        file = os.path.basename(file)
        with open(f"{LIB_DIR}/{lint_dir}/{file}", "r") as sources:
            lines = sources.readlines()
        with open(f"{build_dir}/{lint_dir}/{file}", "w") as sources:
            for line in lines:
                sources.write(re.sub(r"IOB_CORE_NAME", core_name, line))

    copy_files(
        f"{setup_dir}/{lint_dir}", f"{build_dir}/{lint_dir}", [], "*", copy_all=True
    )


# synthesis
def syn_setup(python_module):
    build_dir = python_module.build_dir
    setup_dir = python_module.setup_dir
    syn_dir = "hardware/syn"

    shutil.copytree(f"{setup_dir}/{syn_dir}", f"{build_dir}/{syn_dir}")
    for file in Path(f"{LIB_DIR}/{syn_dir}").rglob("*"):
        src_file = file.as_posix()
        dest_file = re.sub(LIB_DIR, build_dir, src_file)
        if os.path.isfile(src_file):
            os.makedirs(os.path.dirname(dest_file), exist_ok=True)
            shutil.copyfile(f"{src_file}", f"{dest_file}")


# Check if any *_setup.py modules exist (like sim_setup.py, fpga_setup.py, ...).
# If so, get a function to execute them and add them to the 'modules' list of the 'submodules' variable in the 'python_module'
# This will allow these modules to be executed during setup
#    python_module: python module of *_setup.py of the core/system, should contain setup_dir
#    **kwargs: set of objects that will be accessible from inside the modules when they are executed
def add_setup_functions(python_module, module_type, **kwargs):
    # Check if any *_setup.py modules exist. If so, get a function to execute them and add them to the 'modules' list
    module_path = {
        "sim_setup": "hardware/simulation/sim_setup.py",
        "fpga_setup": "hardware/fpga/fpga_setup.py",
        "sw_setup": "software/sw_setup.py",
    }[module_type]
    full_module_path = os.path.join(python_module.setup_dir, module_path)
    if os.path.isfile(full_module_path):
        # Make sure dictionary exists
        if module_type not in python_module.submodules:
            python_module.submodules[module_type] = {"headers": [], "modules": []}
        # Append executable module to 'modules' list of the submodules dictionary
        # The fuctions will be executed during setup
        python_module.submodules[module_type]["modules"].append(
            get_module_function(full_module_path, **kwargs)
        )


# Get an executable function to run a given python module
#    module_path: python module path
#    **kwargs: set of objects that will be accessible from inside the module when it is executed
# Example: get_module_function("sim_setup.py",setup_module=python_module)
def get_module_function(module_path, **kwargs):
    # Create function to execute module if it exists
    def module_function():
        if os.path.isfile(module_path):
            module_name = os.path.basename(module_path).split(".")[0]
            spec = importlib.util.spec_from_file_location(module_name, module_path)
            module = importlib.util.module_from_spec(spec)
            sys.modules[module_name] = module
            # Define module objects given via kwargs
            for key, value in kwargs.items():
                vars(module)[key] = value
            spec.loader.exec_module(module)

    return module_function


# Setup simulation related files/modules
# module: python module representing a *_setup.py file of the root directory of the core/system.
def sw_setup(python_module):
    core_flows = python_module.flows
    build_dir = python_module.build_dir
    setup_dir = python_module.setup_dir

    # Make sure 'sw_setup' dictionary exists
    if "sw_setup" not in python_module.submodules:
        python_module.submodules["sw_setup"] = {"headers": [], "modules": []}

    sw_setup = python_module.submodules["sw_setup"]
    # This can only contain .h files
    sw_headers = sw_setup["headers"]
    # This list may contain .c files, LIB python_modules, or functions to be called.
    sw_srcs = sw_setup["modules"]

    set_default_submodule_dirs(
        python_module
    )  # Make sure that dictionary submodules dirs exists (set default directory for non existing ones)
    submodule_dirs = python_module.submodules["dirs"]

    # append this core hw flows to config_build
    if "emb" not in core_flows:
        mk_conf.append_flows_config_build_mk(core_flows, ["emb"], build_dir)
    if "pc-emul" not in core_flows:
        mk_conf.append_flows_config_build_mk(core_flows, ["pc-emul"], build_dir)

    # Copy software tree if it exists as this core may contain software sources to be used by others
    if os.path.isdir(f"{setup_dir}/software"):
        shutil.copytree(
            f"{setup_dir}/software",
            f"{build_dir}/software",
            dirs_exist_ok=True,
            copy_function=copy_without_override,
            ignore=shutil.ignore_patterns("*_setup*"),
        )

    # Add functions to the sw_srcs. These functions call setup modules for software setup (sw_setup.py)
    add_setup_functions(python_module, "sw_setup", setup_module=python_module)
    # Setup any sw submodules by calling the 'sw_setup()' function from their *_setup.py module
    module_dependency_setup(
        sw_srcs,
        sw_headers,
        build_dir,
        submodule_dirs,
        function_2_call="setup.build_srcs.sw_setup",
        lib_dir=LIB_DIR,
    )

    # Copy every .h file of the sw_headers list from LIB
    if sw_headers:
        copy_files(
            LIB_DIR + "/software", f"{build_dir}/software/src", sw_headers, "*.h"
        )
    # Copy every .c file of the sw_srcs list from LIB
    if sw_srcs:
        copy_files(LIB_DIR + "/software", f"{build_dir}/software/src", sw_srcs, "*.c")

    if "emb" in core_flows or "pc-emul" in core_flows:
        # Copy LIB software Makefile
        shutil.copy(f"{LIB_DIR}/software/Makefile", f"{build_dir}/software")

        # Create 'scripts/' directory
        python_setup(build_dir)


def python_setup(build_dir):
    scripts = [
        "sw_defines.py",
        "hw_defines.py",
        "console.py",
        "hex_split.py",
        "makehex.py",
        "board_client.py",
        "iob_colors.py",
    ]
    dest_dir = f"{build_dir}/scripts"
    if not os.path.exists(dest_dir):
        os.mkdir(dest_dir)
    copy_files(LIB_DIR, dest_dir, scripts, "*.py")


def doc_setup(python_module):
    core_flows = python_module.flows
    build_dir = python_module.build_dir
    setup_dir = python_module.setup_dir

    # For cores that have their own documentation
    if "doc" in core_flows:
        shutil.copytree(f"{setup_dir}/document", f"{build_dir}/document")

    # General documentation
    write_git_revision_short_hash(f"{build_dir}/document/tsrc")


def write_git_revision_short_hash(dst_dir):
    file_name = "shortHash.tex"
    text = (
        subprocess.check_output(["git", "rev-parse", "--short", "HEAD"])
        .decode("ascii")
        .strip()
    )

    if not (os.path.exists(dst_dir)):
        os.makedirs(dst_dir)
    file = open(f"{dst_dir}/{file_name}", "w")
    file.write(text)


# Setup a submodule in a given build directory
# build_dir: path to build directory
# submodule_dir: root directory of submodule to run setup function
# module_parameters: optional argument. Allows passing an optional object with parameters to a hardware module (object is passed to the *_setup.py module).
# function_2_call: optional argument. Name of the function to call for module setup. By default is the 'main' function.
def submodule_setup(
    build_dir, submodule_dir, module_parameters=None, function_2_call="main"
):
    # Check if submodule has *_setup.py file
    for fname in os.listdir("."):
        if fname.endswith("_setup.py"):
            iob_submodule_setup(
                build_dir,
                submodule_dir,
                module_parameters=module_parameters,
                function_2_call=function_2_call,
            )
            return

    # Did not find *_setup.py file, copy sources only
    shutil.copytree(f"{submodule_dir}/hardware/src", f"{build_dir}/hardware/src")


# Setup a submodule in a given build directory using its *_setup.py file
# build_dir: destination build directory
# submodule_dir: root directory of submodule to run setup function
# module_parameters: optional argument. Allows passing an optional object with parameters to a hardware module.
# function_2_call: optional argument. Name of the function to call for module setup. By default is the 'main' function. If the function accepts the 'module' argument, then it will be passed.
def iob_submodule_setup(
    build_dir, submodule_dir, module_parameters=None, function_2_call="main"
):
    # print(f"################# {function_2_call}") #DEBUG
    # Import <corename>_setup.py
    # Always set he 'not_top_module' to True, in order to signal that the module was imported
    # Always set a build_dir and submodule_dir by default
    module = import_setup(
        submodule_dir,
        not_top_module=True,
        build_dir=build_dir,
        setup_dir=submodule_dir,
        module_parameters=module_parameters,
    )
    # Split string to check if function is inside a module
    function_2_call = function_2_call.split(".")
    # Check if function is inside other module(s)
    module_with_function = module
    for i in function_2_call[:-1]:
        # print(f"######## {vars(module_with_function)}") #DEBUG
        module_with_function = vars(module_with_function)[i]
    function_2_call = vars(module_with_function)[function_2_call[-1]]
    # Call setup function specified in function_2_call. Pass 'module' as argument if possible.
    if "python_module" in inspect.signature(function_2_call).parameters.keys():
        function_2_call(python_module=module)
    else:
        function_2_call()


# hardware_srcs: list that may contain 4 types of entries:
#                   - function: This entry defines a function to call.
#                   - submodule: This entry defines a submodule to include (may contain *_setup.py or just a set of sources). Can be a tuple, where the first item is the submodule, the second item is a dictionary with module parameters.
#                   - python include: This entry defines a python module that contains a list of other hardware modules/headers.
#                   - verilog source:  This entry defines either a C source (.c) or verilog source (.c) file to include.
# function_2_call: optional argument. Name of the function to call for module setup. By default is the 'main' function.
def module_dependency_setup(
    srcs, headers, build_dir, submodule_dirs, function_2_call="main", lib_dir=LIB_DIR
):
    # Remove all non *.v and *.vh entries from srcs
    # Do this by setting up submodules and including modules
    while True:
        # Handle each entry, skipping .v and .vh entries
        for idx, src in enumerate(srcs):
            # print(f"############ {src} {function_2_call}") # DEBUG
            # Entry is a tuple, therefore it contains optional parameters
            if type(src) == tuple:
                # Save optional_parameters in a variable
                optional_parameters = src[1]
                # Convert src to a string
                src = src[0]
            else:
                optional_parameters = None

            # Entry is a function
            if callable(src):
                src()
                srcs.pop(idx)
                break
            # Entry is a 'submodule'
            elif src in submodule_dirs:
                submodule_setup(
                    build_dir,
                    submodule_dirs[src],
                    function_2_call=function_2_call,
                    module_parameters=optional_parameters,
                )
                srcs.pop(idx)
                break
            # Entry is a 'python include' (software)
            elif "sw_setup" in function_2_call:
                if not src.endswith(".c"):
                    lib_module_setup(
                        headers,
                        srcs,
                        src,
                        lib_dir,
                        module_parameters=optional_parameters,
                        module_extension=".c",
                    )
                    srcs.pop(idx)
                    break
            # Entry is a 'python include' (hardware)
            elif not src.endswith(".v"):
                lib_module_setup(
                    headers,
                    srcs,
                    src,
                    lib_dir,
                    add_sim_srcs=True if "sim_setup" in function_2_call else False,
                    add_fpga_srcs=True if "fpga_setup" in function_2_call else False,
                    module_parameters=optional_parameters,
                )
                srcs.pop(idx)
                break
        # Did not find any non .v or .c entry
        else:
            break


# Include headers and srcs from given python module (module_name)
# headers: List of headers that will be appedend by the list of headers in the .py module.
# srcs: List of srcs that will be appedend by the list of srcs in the .py module.
# module_name: name of the python module to include. Can also be the name of a src module (with the same extension as passed in the module_extension parameter).
# LIB_DIR: root directory of the LIB
# add_sim_srcs: If True, then the list of simulation sources will be appended to the srcs list
# add_fpga_srcs: If True, then the list of FPGA sources will be appended to the srcs list
# module_parameters: optional argument. Allows passing an optional object with parameters to a hardware module.
# module_extension: Select module file extension (.v for hardware, .c for software)
def lib_module_setup(
    headers,
    srcs,
    module_name,
    lib_dir=LIB_DIR,
    add_sim_srcs=False,
    add_fpga_srcs=False,
    module_parameters=None,
    module_extension=".v",
):
    module_path = None

    # Search for module_name.py
    for mod_path in Path(lib_dir).rglob(f"{module_name}.py"):
        module_path = mod_path
        break
    # If module_name.py is not found, search for module_name.module_extension
    if not module_path:
        for mod_path in Path(lib_dir).rglob(f"{module_name}{module_extension}"):
            module_path = mod_path
            break
    # Exit if module is not found
    if not module_path:
        sys.exit(
            f"{iob_colors.FAIL} {module_name} is not a LIB module.{iob_colors.ENDC}"
        )

    extension = os.path.splitext(module_path)[1]
    # If module_name.py is found, import the headers and srcs lists from it
    if extension == ".py":
        lib_module_name = os.path.basename(module_path).split(".")[0]
        spec = importlib.util.spec_from_file_location(lib_module_name, module_path)
        lib_module = importlib.util.module_from_spec(spec)
        sys.modules[lib_module_name] = lib_module
        if module_parameters:
            lib_module.module_parameters = module_parameters
        spec.loader.exec_module(lib_module)
        headers.extend(lib_module.headers)
        srcs.extend(lib_module.modules)
        if add_sim_srcs and (
            hasattr(lib_module, "sim_headers") and hasattr(lib_module, "sim_modules")
        ):
            headers.extend(lib_module.sim_headers)
            srcs.extend(lib_module.sim_modules)
        if add_fpga_srcs and (
            hasattr(lib_module, "fpga_headers") and hasattr(lib_module, "fpga_modules")
        ):
            headers.extend(lib_module.fpga_headers)
            srcs.extend(lib_module.fpga_modules)
    # If module_name.module_extension is found, add it to the srcs list
    elif extension == module_extension:
        srcs.append(f"{module_name}{module_extension}")


def copy_files(src_dir, dest_dir, sources=[], pattern="*", copy_all=False):
    files_copied = []
    if (sources != []) or copy_all:
        os.makedirs(dest_dir, exist_ok=True)
        for path in Path(src_dir).rglob(pattern):
            file = path.name
            if (file in sources) or copy_all:
                src_file = path.resolve()
                dest_file = f"{dest_dir}/{file}"
                if os.path.isfile(src_file) and (
                    not (os.path.isfile(dest_file))
                    or (os.stat(src_file).st_mtime < os.stat(dest_file).st_mtime)
                ):
                    shutil.copy(src_file, dest_file)
                    files_copied.append(file)
                elif not (os.path.isfile(src_file)):
                    print(
                        f"{iob_colors.WARNING}{src_file} is not a file.{iob_colors.ENDC}"
                    )
    else:
        print(
            f"{iob_colors.WARNING}'copy_files' function did nothing.{iob_colors.ENDC}"
        )
    return files_copied


# Create verilog headers for the interfaces in Vheaders list, using if_gen.py
# This function will remove all if_gen entries from the Vheaders list. It will leave the .vh files in that list.
def create_if_gen_headers(dest_dir, Vheaders):
    non_if_gen_interfaces = []
    for vh_name in Vheaders:
        if type(vh_name) == str and vh_name.endswith(".vh"):
            # Save this entry as a .vh file.
            non_if_gen_interfaces.append(vh_name)
            continue  # Skip if_gen for this entry
        elif (type(vh_name) is str) and (vh_name in if_gen.interfaces):
            if "iob_" in vh_name:
                file_prefix = ""
            else:
                file_prefix = "iob_"
            f_out = open(f"{dest_dir}/{file_prefix}{vh_name}.vh", "w")
            if_gen.create_signal_table(vh_name)
            if_gen.write_vh_contents(vh_name, "", "", f_out)
        elif (type(vh_name) is dict) and (vh_name["interface"] in if_gen.interfaces):
            f_out = open(
                f"{dest_dir}/{vh_name['file_prefix']}{vh_name['interface']}.vh", "w"
            )
            if_gen.create_signal_table(vh_name["interface"])
            if_gen.write_vh_contents(
                vh_name["interface"],
                vh_name["port_prefix"],
                vh_name["wire_prefix"],
                f_out,
                bus_size=vh_name["bus_size"] if "bus_size" in vh_name.keys() else 1,
                bus_start=vh_name["bus_start"] if "bus_start" in vh_name.keys() else 0,
            )
        else:
            sys.exit(
                f"{iob_colors.FAIL} {vh_name} is not an available header.{iob_colors.ENDC}"
            )
    # Save the list of non if_gen interfaces (will only contain .vh files)
    Vheaders = non_if_gen_interfaces


def version_file(core_name, core_version, core_previous_version, build_dir):
    tex_dir = f"{build_dir}/document/tsrc"
    verilog_dir = f"{build_dir}/hardware/src"

    if os.path.isdir(tex_dir):
        tex_file = f"{tex_dir}/{core_name}_version.tex"
        with open(tex_file, "w") as tex_f:
            tex_f.write(core_version)
        tex_file = f"{tex_dir}/{core_name}_previous_version.tex"
        with open(tex_file, "w") as tex_f:
            tex_f.write(core_previous_version)

    vh_file = f"{verilog_dir}/{core_name}_version.vh"
    vh_version_string = "0"
    for c in core_version:
        if c.isdigit():
            vh_version_string += c
    with open(vh_file, "w") as vh_f:
        vh_f.write(f"`define VERSION {vh_version_string}")


# Given a version string (like "V0.12"), return a 4 digit string representing the version (like "0012")
def version_str_to_digits(version_str):
    version_str = version_str.replace("V", "")
    major_ver, minor_ver = version_str.split(".")
    return f"{int(major_ver):02d}{int(minor_ver):02d}"
