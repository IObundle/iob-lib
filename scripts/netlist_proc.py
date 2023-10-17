#!/usr/bin/env python3

import argparse
import re
import sys


def process_netlist(input, output, top_module):
    print(f"Processing {input} to {output}")

    # search pattern: "module <name>"
    pattern = r"module\s+(\w+)"

    # Read input netlist
    with open(input, "r") as file:
        content = file.read()

    netlist_modules = []
    # Iterate through the lines and look for the pattern
    for line in content.splitlines():
        match = re.search(pattern, line)
        if match:
            module_name = match.group(1)
            netlist_modules.append(module_name)

    # Remove top module
    netlist_modules = [line for line in netlist_modules if line != top_module]

    # replace all instances of <module name> with _<module_name>
    for module_name in netlist_modules:
        print(f"Replacing {module_name} with _{module_name}", file=sys.stderr)
        replacement_string = f"_{module_name}"
        content = content.replace(module_name, replacement_string)

    # write processed netlist
    with open(output, "w") as f:
        f.write(content)


def parse_args():
    parser = argparse.ArgumentParser(description="IObundle Netlist Processing Script")
    parser.add_argument("input", help="Input netlist file.")
    parser.add_argument("output", help="Output netlist file.")
    parser.add_argument("-t", help="Netlist top level module.")
    return parser.parse_args()


if __name__ == "__main__":
    print("Netlist Processing Script")
    args = parse_args()
    print(args)
    process_netlist(args.input, args.output, args.t)
    pass
