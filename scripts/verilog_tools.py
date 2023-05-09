#!/usr/bin/env python3
import os
import iob_colors
import re

DEBUG = False

# code: list of lines of code
# files: dictionary of files that can be included
#        Dictionary format: {filename: path}
# ignore_files: list of files that should not be included
# replace_all: boolean to replace all includes, even if they are not inside a module


def replace_includes_in_code(code, files, ignore_files=[], replace_all=False):
    new_lines = []
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
        # Don't include duplicates
        if filename in ignore_files:
            new_lines.append(line)
            continue
        # Dont include files that don't exist
        if filename not in files:
            new_lines.append(line)
            if DEBUG:
                print(
                    f"{iob_colors.WARNING}File '{filename}' not found. Not replacing include.{iob_colors.ENDC}"
                )
            continue
        # Include verilog header contents in the new_lines list
        with open(files[filename] + "/" + filename, "r") as f:
            new_lines += replace_includes_in_code(f.readlines(), files, ignore_files, True)
    return new_lines


# Function to search recursively for every verilog file inside the search_path
# Find include statements inside those files and replace them by the contents of the included file


def replace_includes(search_paths=[]):
    # Search recursively for every verilog file inside the search_path and place them in a list
    verilog_files = {}
    duplicates = []
    for path in search_paths:
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith(".v") or file.endswith(".sv") or file.endswith(".vh"):
                    if file in verilog_files and file not in duplicates:
                        duplicates.append(file)
                        if DEBUG:
                            print(
                                f"{iob_colors.INFO}Duplicate verilog file '{file}' found. Will not replace include.{iob_colors.ENDC}"
                            )
                    if file not in verilog_files:
                        verilog_files[file] = root

    # Search contents of the verilog files for `include statements
    for filename in verilog_files:
        # print(f"{iob_colors.INFO}Replacing includes in '{filename}'{iob_colors.ENDC}")
        with open(verilog_files[filename] + "/" + filename, "r") as f:
            lines = f.readlines()

        new_lines = replace_includes_in_code(lines, verilog_files, duplicates, False)

        # Write new_lines to the file
        with open(verilog_files[filename] + "/" + filename, "w") as f:
            f.writelines(new_lines)
