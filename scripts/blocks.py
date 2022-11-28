#!/usr/bin/env python3
#
#    blocks.py: instantiate Verilog modules and generate their documentation
#

from latex import write_table

# Generate blocks.tex file with list TeX tables of blocks (Verilog modules)
def generate_blocks_list_tex(blocks, out_dir):
    blocks_file = open(f"{out_dir}/blocks.tex", "w")

    blocks_file.write("The Verilog modules of the core are described in the following tables.\n")

    for table in blocks:
        blocks_file.write(\
'''
\\begin{table}[H]
  \centering
  \\begin{tabular}{|l|l|r|p{10.5cm}|}
    
    \hline
    \\rowcolor{iob-green}
    {\\bf Name} & {\\bf Description}  \\\\ \hline \hline

    \input '''+table['name']+'''_module_tab
 
  \end{tabular}
  \caption{'''+table['descr']+'''}
  \label{'''+table['name']+'''_module_tab:is}
\end{table}
'''
        )

    blocks_file.write("\clearpage")
    blocks_file.close()

# Generate TeX tables of blocks
def generate_blocks_tex(blocks, out_dir):
    # Create blocks.tex file
    generate_blocks_list_tex(blocks,out_dir)

    for table in blocks:
        tex_table = []
        for module in table['blocks']:
            tex_table.append([module['name'].replace('_','\_'),module['descr'].replace('_','\_')])

        write_table(f"{out_dir}/{table['name']}_module",tex_table)
