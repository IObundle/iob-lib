#!/usr/bin/env python3
import os
import iob_colors
import re

DEBUG = False

# code: list of lines of code
# files: dictionary of files that can be included
#        Dictionary format: {filename: path}
# replace_all: boolean to replace all includes, even if they are not inside a module
# Returns: (list of lines of code with includes replaced, list of files included)


def replace_includes_in_code(code, files, replace_all=False):
    new_lines = []
    files_included = []
    found_module_start = replace_all
    # Search for lines starting with `include inside the verilog file
    for line in code:
        if not found_module_start:
            # Check if line starts with Verilog module, ignoring spaces and tabs
            if line.lstrip().startswith("module "):
                found_module_start = True
            # Ignore lines before module start
            new_lines.append(line)
            continue

        # Ignore lines that don't start with `include, ignoring spaces and tabs
        if not line.lstrip().startswith("`include"):
            new_lines.append(line)
            continue

        # Ignore lines after module end unless replace_all is True
        if not replace_all and line.lstrip().startswith("endmodule"):
            found_module_start = False
            new_lines.append(line)
            continue

        # Get filename from `include statement
        filename = (
            line.split("`include")[1].split("//")[0].strip().strip('"').strip("'")
        )
        # Dont include files that don't exist
        if filename not in files:
            new_lines.append(line)
            if DEBUG:
                print(
                    f"{iob_colors.WARNING}File '{filename}' not found. Not replacing include.{iob_colors.ENDC}"
                )
            continue

        # Include verilog header contents in the new_lines list
        # Note: it will only include the contents of the first file found with this name.
        with open(files[filename][0] + "/" + filename, "r") as f:
            _lines, _files_included = replace_includes_in_code(
                f.readlines(), files, True
            )
            new_lines += _lines
            files_included += _files_included

        # Add this filename to files_included list
        files_included.append(filename)

    return new_lines, files_included


# Function to search recursively for every verilog file inside the search_path
# Find include statements inside those files and replace them by the contents of the included file


def replace_includes(search_paths=[]):
    files_to_delete = []
    # Search recursively for every verilog file inside the search_path and place them in a list
    verilog_files = {}
    for path in search_paths:
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith(".v") or file.endswith(".sv") or file.endswith(".vh"):
                    if file not in verilog_files:
                        verilog_files[file] = []
                    verilog_files[file].append(root)

    # Search contents of the verilog files for `include statements
    for filename in verilog_files:
        for filepath in verilog_files[filename]:
            # print(f"{iob_colors.INFO}Replacing includes in '{filename}'{iob_colors.ENDC}")
            with open(filepath + "/" + filename, "r") as f:
                lines = f.readlines()

            new_lines, _files_included = replace_includes_in_code(
                lines, verilog_files, False
            )
            files_to_delete += _files_included

            # Write new_lines to the file
            with open(filepath + "/" + filename, "w") as f:
                f.writelines(new_lines)

    # Remove duplicate files to delete
    files_to_delete = list(set(files_to_delete))

    # Delete included files
    for filename in files_to_delete:
        for filepath in verilog_files[filename]:
            os.remove(filepath + "/" + filename)
