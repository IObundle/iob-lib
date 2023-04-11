#!/usr/bin/env python3

import argparse
import subprocess


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        prog="black_format",
        description="""Python Black format script.
        Format all python files (*.py) in repository.""",
    )
    parser.add_argument(
        "-c", "--check", action="store_true", help="Check if files need formatting"
    )
    parser.add_argument(
        "-d", "--diff", action="store_true", help="Display format changes"
    )

    args = parser.parse_args()

    black_flags = ""
    if args.check:
        black_flags += " --check"
    if args.diff:
        black_flags += " --diff"

    # git ls-files: pipe only git tracked files into black. Does not include
    # submodule files
    format_cmd = f"git ls-files *.py | xargs black {black_flags}"

    subprocess.run(format_cmd, shell=True, check=True)
