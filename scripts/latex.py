#!/usr/bin/env python3
# Script with LaTeX related functions

"""
Write Latex table
"""


def write_table(outfile, table):
    fout = open(outfile + "_tab.tex", "w")
    for i in range(len(table)):
        if (i % 2) != 0:
            fout.write("\\rowcolor{iob-blue}\n")
        line = table[i]
        line_out = str(line[0])
        for l in range(1, len(line)):
            line_out = line_out + (" & %s" % line[l])
        fout.write(line_out + " \\\ \hline\n")

    fout.close()
    return


"""
Write Latex description
"""


def write_description(outfile, text):
    fout = open(outfile + "_desc.tex", "w")
    for line in text:
        fout.write("\item[" + line[0] + "] " + "{" + line[1] + "}\n")
    fout.close()
