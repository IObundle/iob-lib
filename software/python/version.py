#!/usr/bin/env python3

import sys

if len(sys.argv) < 3 or len(sys.argv) > 3:
    print ("You must set two argument!!!")
    sys.exit()

def numbers(s):
    try:
        int(s)
        return True
    except ValueError:
        return False

for arg in sys.argv[2]:
    if not numbers(arg):
        sys.exit("second argument must be integers. Exit.")

for arg in sys.argv[1]:
    if numbers(arg):
        sys.exit("the first argument should not be numbers!")

text= sys.argv[1]
        
a = sys.argv[2]

fh = int(a[:2])

sh = int(a[2:])

thename = ("{}_V{}.{}".format(text,fh,sh))

print (thename)

#the path should be indicated
the_path = "./software/python/"

thecompletefile = ("{}{}.vh".format(the_path,thename))

f = open(thecompletefile, "w+")

f.write("`define VERSION {}".format(int(a)))

f.close()


