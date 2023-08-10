#!/usr/bin/env python3
# Python script to search and add python modules under the given search path directory.
# It also instatiates the top module, provided the  class name matches the name of the file containing it.
import os
import sys
import datetime

if len(sys.argv) < 2:
    print(
        "Usage: %s <top_module_name> [setup_args] [-s <search_path>] [-f <func_name>]"
        % sys.argv[0]
    )
    print(
        "<top_module_name>: Name of top module class and file (they must have the same name)."
    )
    print(
        "-s <search_path>: Optional root of search path for python modules. Defaults to current directory."
    )
    print("-f <func_name>: Optional function name to execute")
    print(
        "setup_args: Optional project-defined arguments that may be using during setup process of the current project."
    )
    exit(0)

search_path = "."
if "-s" in sys.argv:
    search_path = sys.argv[sys.argv.index("-s") + 1]


# Search for files under the given directory using a breadth-first search
def bfs_search_files(search_path):
    dirs = [search_path]
    return_values = []
    # while there are dirs to search
    while len(dirs):
        nextDirs = []
        for parent in dirs:
            # Create a tuple for this directory containing the path and a list of files in it
            dir_tuple = (parent, [])
            return_values.append(dir_tuple)
            # Scan this dir
            for f in os.listdir(parent):
                # if there is a dir, then save for next ittr
                # if it is a file then save it in dir_tuple
                ff = os.path.join(parent, f)
                if os.path.isdir(ff):
                    nextDirs.append(ff)
                else:
                    dir_tuple[1].append(f)
        # once we've done all the current dirs then
        # we set up the next itter as the child dirs
        # from the current itter.
        dirs = nextDirs
    return return_values


# Add python modules search paths for every module
print(f"Searching for modules under '{search_path}'...", file=sys.stderr)
found_modules = []
for filepath, files in bfs_search_files(search_path):
    for filename in files:
        if filename.endswith(".py") and filename not in found_modules:
            sys.path.append(filepath)
            found_modules.append(filename)

# Import top module
top_module_name = sys.argv[1].split(".")[0]
exec("import " + top_module_name)


# Set a custom LIB directory
for arg in sys.argv:
    if "LIB_DIR" in arg:
        import build_srcs

        build_srcs.LIB_DIR = arg.split("=")[1]
        break


# Insert header in source files
def insert_header():
    # invoked from the command line as:
    # python3 bootstrap.py <top_module_name> -f insert_header -h <header_file> <comment> <file1> <file2> <file3> ...
    # where
    # <header_file> is the name of the header file to be inserted.
    # <comment> is the comment character to be used
    # <file1> <file2> <file3> ... are the files to be processed

    x = datetime.datetime.now()

    top_module = vars(sys.modules[top_module_name])[top_module_name]
    top_module.is_top_module = True
    top_module.init_attributes()

    NAME, VERSION = top_module.name, top_module.version

    h_arg_index = sys.argv.index("-h")

    # header is in the file whose name is given in the first argument after `-h`
    f = open(sys.argv[h_arg_index + 1], "r")
    header = f.readlines()
    print(header)
    f.close()

    for filename in sys.argv[h_arg_index + 3 :]:
        f = open(filename, "r+")
        content = f.read()
        f.seek(0, 0)
        for line in header:
            f.write(sys.argv[h_arg_index + 2] + "  " + f"{line}")
        f.write("\n\n\n" + content)


# Given a version string, return a 4 digit representation of that version.
def version_from_str(version_str):
    major, minor = version_str.replace("V", "").split(".")
    version_str = f"{int(major):02d}{int(minor):02d}"
    return version_str


# Print Makefile variable definitions, used for delivery
def get_delivery_vars():
    top_module = vars(sys.modules[top_module_name])[top_module_name]
    top_module.is_top_module = True
    top_module.init_attributes()
    print(f"NAME={top_module.name} ", end="")
    print(f"VERSION={version_from_str(top_module.version)} ", end="")
    print(f"PREVIOUS_VERSION={version_from_str(top_module.previous_version)} ", end="")
    print(f"VERSION_STR={top_module.version} ")


# Print build directory attribute of the top module
def get_build_dir():
    top_module = vars(sys.modules[top_module_name])[top_module_name]
    top_module.is_top_module = True
    top_module.init_attributes()
    print(top_module.build_dir)


# Instantiate top module to start setup process
def instantiate_top_module():
    vars(sys.modules[top_module_name])[top_module_name].setup_as_top_module()


# Call either the default function or the one given by the user
function_2_call = "instantiate_top_module"
if "-f" in sys.argv:
    function_2_call = sys.argv[sys.argv.index("-f") + 1]
print(f"Calling '{function_2_call}'...", file=sys.stderr)
vars()[function_2_call]()
