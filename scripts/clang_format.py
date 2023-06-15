#!/usr/bin/env python3

import argparse
import subprocess


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="clang_format",
        description="""Clang format script.
        Format all C/C++ files (*.h, *.c, *.cpp, *.hpp) in repository.""",
    )
    parser.add_argument(
        "-c", "--check", action="store_true", help="Check if files need formatting"
    )

    args = parser.parse_args()

    clang_flags = "-i -style=file -fallback-style=none -Werror"
    if args.check:
        clang_flags += " -dry-run"

    # git ls-files: pipe only git tracked files into clang-format. Does not include
    # submodule files
    file_extentions = "*.c *.h *.cpp *.hpp"
    files = subprocess.run(
        f"git ls-files {file_extentions}",
        shell=True,
        check=True,
        capture_output=True,
        text=True,
    )

    if files.stdout:
        format_cmd = (
            f"git ls-files {file_extentions} | xargs clang-format {clang_flags}"
        )
        subprocess.run(format_cmd, shell=True, check=True)
        print(format_cmd)
