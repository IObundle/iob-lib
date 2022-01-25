#!/usr/bin/python3
#
#    Add defines from .vh to local dictionary
#

import sys
import os.path
import re

def header_parse (vhfile):
    f = open(vhfile, 'r')
    defines = {}
    for line in f:
        #ignore leading spaces
        line = line.lstrip() 
        
        #replace $clog2 by clog2
        line = line.replace("$", "")
        
        #remove tabs
        line = line.replace("\t", "")
        
        #split line elements in array
        line = re.sub(' +', ' ', line)
        values = line.split("\n")
        values = values[0].split(" ")
        
        #parser
        lookup = {}
        if "`define" == values[0]:
            if(len(values) > 2):
                if values[2].isdigit() == False:
                    if "'d" in line:
                        const = line.split("'d")
                        const = const[1].split(" ")
                        const[0] = re.search(r'\d+', const[0]).group()
                        lookup["`" + values[1]] = int(const[0],10)
                    elif "'h" in line:
                        const = line.split("'h")
                        const = const[1].split(" ")
                        lookup["`" + values[1]] = int(const[0],16)
                    elif "'b" in line:
                        const = line.split("'b")
                        const = const[1].split(" ")
                        lookup["`" + values[1]] = int(const[0],2)
                    elif "(" in line:
                        line = re.sub('`', '', line)
                        if "'b" in line:
                            line = re.sub('1\'b', '', line)
                        if '**' in line:
                            line = re.sub('2\*\*', '(1<<', line)
                            line = re.sub(re.escape(' +'), ') +', line)
                            line = re.sub(re.escape('-1)'), ')-1', line)
                            line = re.sub(re.escape('-2)'), ')-2', line)
                        const = line.split("(", 1)
                        const = const[1].split("//")
                        const = const[0].split('\n')
                        const = "(" + const[0] 
                        lookup["`" + values[1]] = const
                    elif "{" in line:
                        continue
                    else:
                        const = values[2].split("`")
                        const = const[1].split("\n")
                        lookup["`" + values[1]] = lookup[const[0]]
                else:
                    lookup["`" + values[1]] = int(values[2])
            else:
                lookup[values[0] + " " + values[1]] = ""
        else:
            continue

        #Write to dictionary
        for key, val in lookup.items():
            if val:
                defines.update({key:int(val)})
    
    f.close()
    return defines
    
