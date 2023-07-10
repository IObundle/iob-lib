#!/usr/bin/env python3
import os
import iob_colors
import re


# Function to search recursively for every verilog file inside the search_path
# Find include statements inside those files and replace them by the contents of the included file


def replace_includes(setup_dir="", build_dir=""):
    VSnippetFiles = []
    VerilogFiles = []
    SearchPaths = f"{build_dir}/hardware"
    VSnippetDir = f"{setup_dir}/hardware/aux"

    os.makedirs(VSnippetDir, exist_ok=True)

    for root, dirs, files in os.walk(SearchPaths):
        for file in files:
            if file.endswith(".vs"):
                VSnippetFiles.append(f"{root}/{file}")
                VerilogFiles.append(f"{root}/{file}")
            elif file.endswith(".v") or file.endswith(".sv") or file.endswith(".vh"):
                VerilogFiles.append(f"{root}/{file}")

    for VerilogFile in VerilogFiles:
        with open(VerilogFile, "r") as source:
            lines = source.readlines()
        # for each line in the file, search for the include .vs file statement and replace the include statement with the content of the file
        for line in lines:
            if re.search(r'`include ".*\.vs"', line):
                # retrieve the name of the file to be included
                tail = line.split('"')[1]
                #search for the file to be included in the VSnippetFiles
                for VSnippetFile in VSnippetFiles:
                    if tail in VSnippetFile:
                        # open the file to be included
                        with open(f"{VSnippetFile}", "r") as include:
                            include_lines = include.readlines()
                        # replace the include statement with the content of the file
                        #if the file to be included is *_portmap.vs or *_port.vs and has a ");" in the next line, remove the last comma
                        if re.search(r'`include ".*_portmap\.vs"', line) or re.search(r'`include ".*_port\.vs"', line):
                            if re.search(r'\s*\);\s*', lines[lines.index(line) + 1]):
                                # find and remove the first comma in the last line of the include_lines ignoring white spaces
                                include_lines[-1] = re.sub(r'\s*,\s*', "", include_lines[-1], count=1)
                        # replace the include statement with the content of the file
                        lines[lines.index(line)] = "".join(include_lines)
        # write the new file
        with open(VerilogFile, "w") as source:
            source.writelines(lines)
        
                
        # Maybe for debug it would be good to move them somewhere. However, the directory where it is moved to should be ignored by verible.
        # os.rename(VSnippetFile, f"{VSnippetDir}/{tail}")
        # print(f"{iob_colors.INFO}Deleted file: {VSnippetFile}{iob_colors.ENDC}")
    
    #Remove the VSnippetFiles
    for VSnippetFile in VSnippetFiles:
        os.remove(VSnippetFile)

    print(
        f"{iob_colors.INFO}Replaced Verilog Snippet includes with respective content and deleted the files.{iob_colors.ENDC}"
    )
