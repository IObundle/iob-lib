#!/usr/bin/env python3

import sys

if len(sys.argv) < 2 or len(sys.argv) > 2:
    print "You must set one argument!!!"
    sys.exit()


def nostring(s):
    try:
        int(s)
        return True
    except ValueError:
        return False

for arg in sys.argv[1]:
    if not nostring(arg):
        sys.exit("All arguments must be integers. Exit.")

a = sys.argv[1]

fh = int(a[:2])

sh = int(a[2:])

print ("V{}.{}".format(fh,sh))




