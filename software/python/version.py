#!/usr/bin/env python3

import sys

if len(sys.argv) != 3:
    sys.exit()
core_name = sys.argv[1]
core_version = sys.argv[2]

print("V{}.{}".format(int(core_version[:2]),core_version[2:]))

f = open("./software/python/{}_V{}.{}.vh".format(core_name,int(core_version[:2]),core_version[2:]), "w+")

f.write("`define VERSION {}".format(core_version))

f.close()





