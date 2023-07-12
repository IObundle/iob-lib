import os
import shutil
import sys
import importlib

import iob_colors
import if_gen
from mk_configuration import config_build_mk
import build_srcs
from iob_verilog_instance import iob_verilog_instance


# Generic class to describe a base iob-module
class iob_module:
    # Standard attributes common to all iob-modules
    name = "iob_module"  # Verilog module name (not instance name)
    version = "1.0"  # Module version
    previous_version = None  # Module version
    flows = ""  # Flows supported by this module
    setup_dir = ""  # Setup directory for this module
    build_dir = ""  # Build directory for this module
    confs = None  # List of configuration macros/parameters for this module
    regs = None  # List of registers for this module
    ios = None  # List of I/O for this module
    block_groups = None  # List of block groups for this module. Used for documentation.

    submodule_setup_list = None  # List of submodules to setup

    # List of setup purposes for this module. Also used to check if module has already been setup.
    _setup_purpose = None

    is_top_module = False  # Select if this module is the top module

    # Dictionary of headers generated by the `generate` method, and their purpose.
    __generated_headers = {}

    # Read-only dictionary with relation between the setup_purpose and the corresponding source folder
    PURPOSE_DIRS = {
        "hardware": "hardware/src",
        "simulation": "hardware/simulation/src",
        "fpga": "hardware/fpga/src",
    }

    # Public setup method for this module.
    # This method should not be overriden by subclasses!
    # purpose: Reason for setting up the module. Used to select between the standard destination locations.
    # is_top_module: Select if this is the top module. This should only be enabled on the top module class.
    @classmethod
    def setup(cls, purpose="hardware", is_top_module=False):
        # print(f'DEBUG: Setup: {cls.name}, purpose: {purpose}') # DEBUG

        # Initialize empty list for purpose
        if cls._setup_purpose == None:
            cls._setup_purpose = []

        # Don't setup if module has already been setup for this purpose or for the "hardware" purpose.
        if purpose in cls._setup_purpose or "hardware" in cls._setup_purpose:
            return

        # Only set dynamic attributes if this is the first time we run setup
        if not cls._setup_purpose:
            cls.is_top_module = is_top_module
            cls.set_dynamic_attributes()

        # Create build directory this is the top module class, and is the first time setup
        if is_top_module and not cls._setup_purpose:
            cls.__create_build_dir()

        # Add current setup purpose to list
        cls._setup_purpose.append(purpose)

        cls._run_setup()

    # TODO: Deprecate this method. Instead use constructors to instantiate these classes.
    # Note: The class attibutes will be read only! as they refer to properties of the "type" of verilog module.
    #       However, the instance attributes can be changed. Each instance will essentially have the same attributes as the `iob_verilog_instance` class. That class will also be deprecated with this modification.
    #
    # Public method to create a Verilog instance of this module
    # name: Name of the Verilog instance.
    # *args and **kwargs: Other arguments for the Verilog instance.
    # Returns an `iob_verilog_instance` object representing a new Verilog instance of the module calling this method.
    @classmethod
    def instance(cls, name="", *args, **kwargs):
        assert (
            cls._setup_purpose
        ), f"{iob_colors.FAIL}Module {cls.name} has not been setup yet!{iob_colors.ENDC}"

        if not name:
            name = f"{cls.name}_0"

        # Return a new iob_verilog_instance object with these attributes that describe the Verilog instance and module.
        return iob_verilog_instance(name, *args, module=cls, **kwargs)

    # TODO: Rename this function to `init_attributes`
    # Public method to set dynamic attributes.
    # This method is automatically called by the `setup` method! It should only be called once for each class.
    @classmethod
    def set_dynamic_attributes(cls):
        # Set the build directory in the `iob_module` superclass, so everyone has access to it
        if cls.is_top_module:
            # Auto-fill build directory if its not set
            if not cls.build_dir:
                iob_module.build_dir = f"../{cls.name}_{cls.version}"
            else:
                iob_module.build_dir = cls.build_dir

        # Copy build directory from the `iob_module` superclass
        cls.build_dir = iob_module.build_dir

        # Copy current version to previous version if it is not set
        if not cls.previous_version:
            cls.previous_version = cls.version

        # Initialize empty lists for attributes (We can't initialize in the attribute declaration because it would cause every subclass to reference the same list)
        cls.confs = []
        cls.regs = []
        cls.ios = []
        cls.block_groups = []
        cls.submodule_setup_list = []
        cls._create_submodules_list()

    # Default method to create list of submodules does nothing
    @classmethod
    def _create_submodules_list(cls):
        pass

    # TODO: Rename this function to `_post_setup()`
    # Default _run_setup function copies sources from setup directory of every subclass of iob_module, down to `cls`.
    @classmethod
    def _run_setup(cls):
        cls.__setup_submodules()

        # Setup flows (copy LIB files)
        build_srcs.flows_setup(cls)

        cls._copy_srcs()

        cls._run_setup_files()

    @classmethod
    def _run_setup_files(cls):
        flows_setup_files = {
            "sim": cls.setup_dir + "/hardware/simulation/sim_setup.py",
            "fpga": cls.setup_dir + "/hardware/fpga/fpga_setup.py",
            "emb": cls.setup_dir + "/software/sw_setup.py",
            "doc": cls.setup_dir + "/document/doc_setup.py",
        }
        for flow, filepath in flows_setup_files.items():
            # Skip if flow not in flows list
            if flow not in cls.flows:
                continue

            # Skip if file does not exist
            if not os.path.isfile(filepath):
                continue

            module_name = os.path.basename(filepath).split(".")[0]
            spec = importlib.util.spec_from_file_location(module_name, filepath)
            module = importlib.util.module_from_spec(spec)
            sys.modules[module_name] = module
            # Define setup_module object, corresponding to this class
            vars(module)["setup_module"] = cls
            # Execute setup file
            spec.loader.exec_module(module)

    # Run setup functions for the submodules list stored in the setup_submodules_list
    @classmethod
    def __setup_submodules(cls):
        for submodule in cls.submodule_setup_list:
            _submodule = submodule
            setup_options = {}

            # Split submodule from its setup options (if it is a tuple)
            if type(submodule) == tuple:
                _submodule = submodule[0]
                setup_options = submodule[1]

            # Don't setup submodules that have a purpose different than
            # "hardware" when this class is not the top module
            if (not cls.is_top_module and "purpose" in setup_options
                    and setup_options["purpose"] != "hardware"):
                continue

            if type(_submodule) == str or type(_submodule) == dict:
                # String or dictionary: generate interface with if_gen
                iob_module.generate(_submodule, **setup_options)
            elif issubclass(_submodule, iob_module):
                # Subclass of iob_module: setup the module
                _submodule.setup(**setup_options)
            else:
                # Unknown type
                raise Exception(
                    f"{iob_colors.FAIL}Unknown type in submodule_setup_list of {cls.name}: {_submodule}{iob_colors.ENDC}"
                )

    # Append confs to the current confs class list, overriding existing ones
    @classmethod
    def _setup_confs(cls, confs):
        for conf in confs:
            for _conf in cls.confs:
                if _conf["name"] == conf["name"]:
                    _conf.update(conf)
                    break
            else:
                cls.confs.append(conf)

    # Generate a Verilog header with `if_gen.py`.
    # vs_name: Either a string or a dictionary describing the interface to generate.
    #          Example string: "iob_wire"
    #          Example dictionary:
    #                {
    #                    "file_prefix": "iob_bus_0_2_", # Prefix to include in the generated file name
    #                    "interface": "axi_m_portmap",  # Type of interface/wires to generate. Will also be part of the filename.
    #                    "wire_prefix": "",             # Prefix to include in the generated wire names
    #                    "port_prefix": "",             # Prefix to include in the generated port names
    #                    "param_prefix": "",            # Optional. Prefix to include in parameters of the width of the generated ports/wires.
    #                    "bus_start": 0,                # Optional. Starting index of the bus of wires that we are connecting.
    #                    "bus_size": 2,                 # Optional. Size of the bus of wires that we are creating/connecting.
    #                }
    # purpose: [Optional] Reason for generating the header. Used to select between the standard destination locations.
    #
    # Example function calls:
    # To generate a simple `iob_s_port.vh` file, use: `iob_module.generate("iob_s_port")`
    # To generate an iob_s_port file with a custom prefix in its ports, wires, and filename, use:
    #     iob_module.generate(
    #                {
    #                    "file_prefix": "example_file_prefix_",
    #                    "interface": "iob_s_port",
    #                    "wire_prefix": "example_wire_prefix_",
    #                    "port_prefix": "example_port_prefix_",
    #                    "param_prefix": "example_parameter_prefix_",
    #                })
    @classmethod
    def generate(cls, vs_name, purpose="hardware"):
        dest_dir = os.path.join(cls.build_dir, cls.get_purpose_dir(purpose))

        if (type(vs_name) is str) and (vs_name in if_gen.interfaces):
            if "iob_" in vs_name:
                file_prefix = ""
            else:
                file_prefix = "iob_"
            f_out = open(os.path.join(dest_dir, file_prefix + vs_name + ".vs"), "w")
            if_gen.create_signal_table(vs_name)
            if_gen.write_vs_contents(vs_name, "", "", f_out)
        elif (type(vs_name) is dict) and (vs_name["interface"] in if_gen.interfaces):
            f_out = open(
                os.path.join(
                    dest_dir, vs_name["file_prefix"] + vs_name["interface"] + ".vs"
                ),
                "w",
            )
            if_gen.create_signal_table(vs_name["interface"])
            if_gen.write_vs_contents(
                vs_name["interface"],
                vs_name["port_prefix"],
                vs_name["wire_prefix"],
                f_out,
                param_prefix=vs_name["param_prefix"]
                if "param_prefix" in vs_name.keys()
                else "",
                bus_size=vs_name["bus_size"] if "bus_size" in vs_name.keys() else 1,
                bus_start=vs_name["bus_start"] if "bus_start" in vs_name.keys() else 0,
            )
        else:
            raise Exception(
                f"{iob_colors.FAIL} Can't generate '{vs_name}'. Type not recognized.{iob_colors.ENDC}"
            )

    # Get output directory based on the purpose given.
    @classmethod
    def get_purpose_dir(cls, purpose):
        assert (
            purpose in cls.PURPOSE_DIRS
        ), f"{iob_colors.FAIL}Unknown purpose {purpose}{iob_colors.ENDC}"
        return cls.PURPOSE_DIRS[purpose]

    # Create build directory. Must be called from the top module.
    @classmethod
    def __create_build_dir(cls):
        assert (
            cls.is_top_module
        ), f"{iob_colors.FAIL}Module {cls.name} is not a top module!{iob_colors.ENDC}"
        os.makedirs(cls.build_dir, exist_ok=True)
        config_build_mk(cls)
        # Create hardware directories
        os.makedirs(f"{cls.build_dir}/hardware/src", exist_ok=True)
        if "sim" in cls.flows:
            os.makedirs(f"{cls.build_dir}/hardware/simulation/src", exist_ok=True)
        if "fpga" in cls.flows:
            os.makedirs(f"{cls.build_dir}/hardware/fpga/src", exist_ok=True)

        shutil.copyfile(
            f"{build_srcs.LIB_DIR}/build.mk", f"{cls.build_dir}/Makefile"
        )  # Copy generic MAKEFILE

    # Copy module sources to the build directory from every subclass in between `ìob_module` and `cls`, inclusive.
    # The function will not copy sources from classes that have no setup_dir (empty string)
    # cls: Lowest subclass
    # (implicit: iob_module: highest subclass)
    # exclude_file_list: list of strings, each string representing an ignore pattern for the source files.
    #                    For example, using the ignore pattern '*.v' would prevent from copying every Verilog source file.
    #                    Note, if want to ignore a file that is going to be renamed with the new core name,
    #                    we would still use the old core name in the ignore patterns.
    #                    For example, if we dont want it to generate the 'new_name_firmware.c' based on the 'old_name_firmware.c',
    #                    then we should add 'old_name_firmware.c' to the ignore list.
    @classmethod
    def _copy_srcs(cls, exclude_file_list=[]):
        previously_setup_dirs = []

        # List of classes, starting from highest superclass (iob_module), down to lowest subclass (cls)
        classes = cls.__mro__[cls.__mro__.index(__class__) :: -1]

        # Go through every subclass, starting for highest superclass to the lowest subclass
        for module_class in classes:
            # Skip classes without setup_dir
            if not module_class.setup_dir:
                continue

            # Skip class if we already setup its directory (it may have inherited the same dir from the superclass)
            if module_class.setup_dir in previously_setup_dirs:
                continue

            previously_setup_dirs.append(module_class.setup_dir)

            # Files that should always be copied
            dir_list = [
                "hardware/src",
                "software",
            ]
            # Files that should only be copied if it is top module
            if cls.is_top_module:
                dir_list += [
                    "hardware/simulation",
                    "hardware/fpga",
                    "hardware/syn",
                    "hardware/lint",
                ]

            # Copy sources
            for directory in dir_list:
                # Skip this directory if it does not exist
                if not os.path.isdir(os.path.join(module_class.setup_dir, directory)):
                    continue

                dst_directory = directory

                # If we are handling the `hardware/src` directory,
                # copy to the correct destination based on `_setup_purpose`.
                if directory == "hardware/src":
                    dst_directory = cls.PURPOSE_DIRS[cls._setup_purpose[-1]]
                    cls.__remove_files_from_prev_setup(directory, module_class)

                # Copy tree of this directory, renaming files, and overriding destination ones.
                shutil.copytree(
                    os.path.join(module_class.setup_dir, directory),
                    os.path.join(cls.build_dir, dst_directory),
                    dirs_exist_ok=True,
                    copy_function=cls.copy_with_rename(module_class.name, cls.name),
                    ignore=shutil.ignore_patterns(*exclude_file_list),
                )

            # Copy document directory if cls is the top module and it has documentation
            if cls.is_top_module and "doc" in cls.flows:
                shutil.copytree(
                    os.path.join(module_class.setup_dir, "document"),
                    os.path.join(cls.build_dir, "document"),
                    dirs_exist_ok=True,
                    ignore=shutil.ignore_patterns(*exclude_file_list),
                )

    @classmethod
    def __remove_files_from_prev_setup(cls, src_dir, module_class):
        '''If we had previously set up this module for another purpose,
        then delete files from that directory, based on the list of files in src_dir.
        :param str src_dir: path to directory with sources (generally "hardware/src")
        :param iob_module module_class: (super)class currently being setup.
        '''
        if len(cls._setup_purpose) > 1:
            _rm_dir = os.path.join(cls.build_dir,
                                   cls.PURPOSE_DIRS[cls._setup_purpose[-2]])

            # Remove every file of _rm_dir that is listed in src dir
            for file in os.listdir(os.path.join(module_class.setup_dir, src_dir)):
                if os.path.isfile(os.path.join(module_class.setup_dir, src_dir, file)):
                    os.remove(os.path.join(_rm_dir, file))


    # Creates a function that:
    #   - Renames any '<old_core_name>' string inside the src file and in its filename, to the given '<new_core_name>' string argument.
    @staticmethod
    def copy_with_rename(old_core_name, new_core_name):
        def copy_func(src, dst):
            dst = os.path.join(
                os.path.dirname(dst),
                os.path.basename(
                    dst.replace(old_core_name, new_core_name).replace(
                        old_core_name.upper(), new_core_name.upper()
                    )
                ),
            )
            # print(f"### DEBUG: {src} {dst}")
            try:
                file_perms = os.stat(src).st_mode
                with open(src, "r") as file:
                    lines = file.readlines()
                for idx in range(len(lines)):
                    lines[idx] = (
                        lines[idx]
                        .replace(old_core_name, new_core_name)
                        .replace(old_core_name.upper(), new_core_name.upper())
                    )
                with open(dst, "w") as file:
                    file.writelines(lines)
            except:
                shutil.copyfile(src, dst)
            # Set file permissions equal to source file
            os.chmod(dst, file_perms)

        return copy_func
