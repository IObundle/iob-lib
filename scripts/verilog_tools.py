#!/usr/bin/env python3
import os
import iob_colors
import re


# Find include statements inside a list of lines and replace them by the contents of the included file and return the new list of lines
def replace_includes_in_lines(lines, VSnippetFiles):
    for line in lines:
        if re.search(r'`include ".*\.vs"', line):
            # retrieve the name of the file to be included
            tail = line.split('"')[1]
            found_vs = False
            for VSnippetFile in VSnippetFiles:
                if tail == os.path.basename(VSnippetFile):
                    found_vs = True
                    # open the file to be included
                    with open(f"{VSnippetFile}", "r") as include:
                        include_lines = include.readlines()
                    # replace the include statement with the content of the file
                    # if the file to be included is *_portmap.vs or *_port.vs and has a ");" in the next line, remove the last comma
                    if re.search(r'`include ".*_portmap\.vs"', line) or re.search(
                        r'`include ".*_port\.vs"', line
                    ):
                        if re.search(r"\s*\);\s*", lines[lines.index(line) + 1]):
                            # find and remove the first comma in the last line of the include_lines ignoring white spaces
                            include_lines[-1] = re.sub(
                                r"\s*,\s*", "", include_lines[-1], count=1
                            )
                    # if the include_lines has an include statement, recursively replace the include statements
                    for include_line in include_lines:
                        if re.search(r'`include ".*\.vs"', include_line):
                            include_lines = replace_includes_in_lines(
                                include_lines, VSnippetFiles
                            )
                    # replace the include statement with the content of the file
                    lines[lines.index(line)] = "".join(include_lines)
                    break
            # if the file to be included is not found in the VSnippetFiles, raise an error
            if not found_vs:
                raise FileNotFoundError(
                    f"{iob_colors.FAIL}File {tail} not found! {iob_colors.ENDC}"
                )
    return lines


# Function to search recursively for every verilog file inside the search_path
def replace_includes(setup_dir="", build_dir=""):
    VSnippetFiles = []
    VerilogFiles = []
    SearchPaths = f"{build_dir}/hardware"

    for root, dirs, files in os.walk(SearchPaths):
        for file in files:
            if file.endswith(".vs"):
                VSnippetFiles.append(f"{root}/{file}")
                VerilogFiles.append(f"{root}/{file}")
            elif file.endswith(".v") or file.endswith(".sv") or file.endswith(".vh"):
                VerilogFiles.append(f"{root}/{file}")

    for VerilogFile in VerilogFiles:
        print(f"Replacing includes in {VerilogFile}")
        with open(VerilogFile, "r") as source:
            lines = source.readlines()
            # replace the include statements with the content of the file
            new_lines = replace_includes_in_lines(lines, VSnippetFiles)
        # write the new file
        with open(VerilogFile, "w") as source:
            source.writelines(new_lines)

    # Remove .vs files from current directory
    for VSnippetFile in VSnippetFiles:
        os.remove(VSnippetFile)

    print(
        f"{iob_colors.INFO}Replaced Verilog Snippet includes with respective content and deleted the files.{iob_colors.ENDC}"
    )


# Insert given verilog code into module defined inside the given verilog source file
# The code will be inserted just before the `endmodule` statement.
def insert_verilog_in_module(verilog_code, verilog_file_path):
    with open(verilog_file_path, "r") as system_source:
        lines = system_source.readlines()
    # Find `endmodule`
    for idx, line in enumerate(lines):
        if line.startswith("endmodule"):
            endmodule_index = idx - 1
            break
    else:
        raise Exception(
            f"{iob_colors.FAIL}verilog_tools.py: Could not find 'endmodule' declaration in '{verilog_file_path}'!{iob_colors.ENDC}"
        )

    # Insert Verilog code
    lines.insert(endmodule_index, verilog_code)

    # Write new system source file
    with open(verilog_file_path, "w") as system_source:
        system_source.writelines(lines)


# Remove given verilog line of code from the given verilog source file
def remove_verilog_line_from_source(verilog_code, verilog_file_path):
    with open(verilog_file_path, "r") as system_source:
        lines = system_source.readlines()
    # Find Verilog line that contains given verilog_code
    line_idx = 0
    while line_idx < len(lines):
        # Remove line if contains verilog_code
        if verilog_code in lines[line_idx]:
            lines.pop(line_idx)
            break
        line_idx += 1

    # Write new system source file
    with open(verilog_file_path, "w") as system_source:
        system_source.writelines(lines)
