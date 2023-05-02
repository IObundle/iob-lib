#!/usr/bin/env python3
import os
import iob_colors

# Function to search recursively for every verilog file inside the search_path
# Find include statements inside those files and replace them by the contents of the included file


def replace_includes(search_paths=[]):
    # Search recursively for every verilog file inside the search_path and place them in a list
    verilog_files = []
    verilog_header_files = {}
    duplicates = []
    for path in search_paths:
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith(".v") or file.endswith(".sv"):
                    verilog_files.append(os.path.join(root, file))
                if file.endswith(".vh"):
                    if file in verilog_header_files and file not in duplicates:
                        duplicates.append(file)
                        print(
                            f"{iob_colors.INFO}Duplicate verilog header file '{file}' found. Will not replace include.{iob_colors.ENDC}"
                        )
                    if file not in verilog_header_files:
                        verilog_header_files[file] = root

    # Search contents of the verilog files for `include statements
    for verilog_file in verilog_files:
        found_module_start = False  # Used to check if we are parsing inside a Verilog module
        # print(f"{iob_colors.INFO}Replacing includes in '{verilog_file}'{iob_colors.ENDC}")
        with open(verilog_file, "r") as f:
            lines = f.readlines()
        new_lines = []
        # Search for lines starting with `include inside the verilog file
        for line in lines:
            if not found_module_start:
                # Check if line starts with Verilog module, ignoring spaces and tabs
                if line.lstrip().startswith("module "):
                    found_module_start = True
                # Ignore lines before module start
                new_lines.append(line)
                continue

            # Check if line starts with `include, ignoring spaces and tabs
            if line.lstrip().startswith("`include"):
                # Get filename from `include statement
                filename = line.split("`include")[1].split(
                    "//")[0].strip().strip('"').strip("'")
                # Don't include duplicates
                if filename in duplicates:
                    new_lines.append(line)
                    continue
                # Dont include files that don't exist
                if filename not in verilog_header_files:
                    new_lines.append(line)
                    print(
                        f"{iob_colors.WARNING}File '{filename}' not found. Not replacing include.{iob_colors.ENDC}"
                    )
                    continue
                # Include verilog header contents in the new_lines list
                with open(verilog_header_files[filename] + "/" + filename, "r") as f:
                    new_lines += f.readlines()
            else:
                new_lines.append(line)
        # Write new_lines to the file
        with open(verilog_file, "w") as f:
            f.writelines(new_lines)
