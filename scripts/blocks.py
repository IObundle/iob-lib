#!/usr/bin/env python3
#
#    blocks.py: instantiate Verilog modules and generate their documentation
#

from latex import write_table
from submodule_utils import get_peripherals

# Generate blocks.tex file with list TeX tables of blocks (Verilog modules)
def generate_blocks_list_tex(blocks, out_dir):
    blocks_file = open(f"{out_dir}/blocks.tex", "w")

    blocks_file.write("The Verilog modules of the core are described in the following tables.\n")

    for table in blocks:
        blocks_file.write(\
'''
\\begin{table}[H]
  \centering
  \\begin{tabularx}{\\textwidth}{|l|X|}
    
    \hline
    \\rowcolor{iob-green}
    {\\bf Name} & {\\bf Description}  \\\\ \hline \hline

    \input '''+table['name']+'''_module_tab
 
  \end{tabularx}
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

# Generate list of blocks, one for each peripheral instance
# Each dictionary is follows the format of a dictionary table in the
# 'blocks' list of the dictionaries in the 'blocks' list of the <corename>_setup.py
# Example list of blocks peripheral instance with one port:
# [{'name':'uart0', 'descr':'UART0 peripheral'},
# {'name':'uart1', 'descr':'UART1 peripheral'},
# {'name':'timer0', 'descr':'TIMER0 peripheral'}]
def get_peripheral_blocks(peripherals_str, root_dir):
    instances_amount, _ = get_peripherals(peripherals_str)
    block_list = []
    for corename in instances_amount:
        for i in range(instances_amount[corename]):
            block_list.append({'name':corename+str(i), 'descr':f'{corename.upper()+str(i)} peripheral'})
    return block_list
