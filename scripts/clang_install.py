#!/usr/bin/env python3

import argparse
import getpass
import subprocess

LLVM_VERSION = "15"

if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        prog="clang_install",
        description="""Install clang tools.
        Automatic installation script for Debian and Ubuntu distributions.
        Check https://apt.llvm.org/ for more information.""",
    )
    parser.add_argument(
        "-v",
        "--version",
        default=LLVM_VERSION,
        help="LLVM Version to install",
    )
    args = parser.parse_args()

    # Download llvm installation script
    subprocess.run("wget https://apt.llvm.org/llvm.sh", shell=True)

    # Change script permissions
    subprocess.run("chmod +x llvm.sh", shell=True)

    # Ask password and sudo install llvm packages
    password = getpass.getpass("Enter sudo password: ")
    install_cmd = f"sudo -S ./llvm.sh {args.version} clang-format"

    proc = subprocess.Popen(install_cmd.split(), stdin=subprocess.PIPE)
    proc.communicate(password.encode())
