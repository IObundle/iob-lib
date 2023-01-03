#!/usr/bin/env python3
# IOb-SoC related functions

from submodule_utils import get_n_periphs, get_n_periphs_w, get_periphs_id_as_macros

# Get peripherals list from 'peripherals' table in blocks list
#blocks: blocks dictionary, contains definition of peripheral instances
#function returns peripherals list
def get_peripherals_list(blocks):
    # Get peripherals list from 'peripherals' table in blocks list
    for table in blocks:
        if table['name'] == 'peripherals':
            peripherals_list = table['blocks']
            break
    else: # No peripherals found
        peripherals_list = []
    return peripherals_list


# Get peripheral related macros
#confs: confs dictionary to be filled with peripheral macros
#peripherals_list: list of peripherals
def get_peripheral_macros(confs, peripherals_list):
    # Append macros with ID of each peripheral
    confs.extend(get_periphs_id_as_macros(peripherals_list))
    # Append macro with number of peripherals
    confs.append({'name':'N_SLAVES', 'type':'M', 'val':get_n_periphs(peripherals_list), 'min':'NA', 'max':'NA', 'descr':"Number of peripherals"})
    # Append macro with width of peripheral bus
    confs.append({'name':'N_SLAVES_W', 'type':'M', 'val':get_n_periphs_w(peripherals_list), 'min':'NA', 'max':'NA', 'descr':"Peripheral bus width"})

