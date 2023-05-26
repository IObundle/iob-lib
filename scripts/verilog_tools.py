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

    if not os.path.isdir(VSnippetDir):
        os.mkdir(VSnippetDir)

    for root, dirs, files in os.walk(SearchPaths):
        for file in files:
            if file.endswith(".vs"):
                VSnippetFiles.append(f"{root}/{file}")
            elif (
                file.endswith(".v")
                or file.endswith(".sv")
                or file.endswith(".vh")
                or file.endswith(".vs")
            ):
                VerilogFiles.append(f"{root}/{file}")

    for VSnippetFile in VSnippetFiles:
        head, tail = os.path.split(VSnippetFile)
        VerilogFiles.remove(VSnippetFile)
        with open(VSnippetFile, "r") as snippet:
            code = snippet.read()
        for VerilogFile in VerilogFiles:
            with open(VerilogFile, "r") as source:
                lines = source.readlines()
            with open(VerilogFile, "w") as source:
                for line in lines:
                    text = re.sub(r'`include "{0}"'.format(tail), code, line)
                    e = source.write(text)
        os.remove(VSnippetFile)
        # Maybe for debug it would be good to move them somewhere. However, the directory where it is moved to should be ignored by verible.
        # os.rename(VSnippetFile, f"{VSnippetDir}/{tail}")
        # print(f"{iob_colors.INFO}Deleted file: {VSnippetFile}{iob_colors.ENDC}")

    print(
        f"{iob_colors.INFO}Replaced Verilog Snippet includes with respective content and deleted the files.{iob_colors.ENDC}"
    )
