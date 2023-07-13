#!/usr/bin/env python3

import sys


def getf(obj, name, field):
    return int(obj[next(i for i in range(len(obj)) if obj[i]["name"] == name)][field])


# If this script is called directly, run function given in first argument
if __name__ == "__main__":
    globals()[sys.argv[1]]()
