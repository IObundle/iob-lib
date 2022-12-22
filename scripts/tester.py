#!/usr/bin/env python3
#
#    tester.py: tester related functions
#
from submodule_utils import import_setup
from ios import get_interface_mapping

# Setup a Tester in a given build directory (without TeX documentation)
# build_dir: path to build directory
# tester_dir: root directory of the tester
# extra_peripherals: list of peripherals to append to the 'peripherals' table in the 'blocks' list of the Tester
# peripheral_dirs: dictionary with directories of each extra peripheral
# peripheral_portmap: Dictionary where each key-value pair is a Mapping between two signals. Example
#                     { {'corename':'UART1', 'if_name':'rs232', 'port':'', 'bits':[]}:{'corename':'UUT', 'if_name':'UART0', 'port':'', 'bits':[]} }
def setup_tester(build_dir, tester_dir, extra_peripherals, peripheral_dirs, peripheral_portmap):
    #Import <corename>_setup.py
    tester = import_setup(tester_dir)

    #Update submodule directories of Tester with new peripherals directories
    tester.submodule_dirs.update(peripheral_dirs)

    #Add extra peripherals to tester list
    tester_peripherals_list=next(i['blocks'] for i in tester.blocks if i['name'] == 'peripherals')
    for peripheral in extra_peripherals:
        # Allow extra peripherals with the same name to override default peripherals
        for default_peripheral in tester_peripherals_list:
            if peripheral['name'] == default_peripheral['name']: default_peripheral = peripheral
            continue # Skip appending peripheral
        tester_peripherals_list.append(peripheral)

    #Handle peripheral portmap
    for mapping in peripheral_portmap.items():
        # Get corename type type of one of the instances in this mapping
        core_type=next(i['type'] for i in peripherals_list if i['name'] == mapping[0]['name'])
        # Import module of the given core type (to access its IO)
        module = import_setup(submodule_dirs[core_type])
        #Get ports of configured interface
        interface_ports=next(i['ports'] for i in module.ios if i['name'] == mapping[0]['if_name'])

        # Check if should insert one port or every port in the interface
        if not mapping[0]['port']:
            # Mapping configuration did not specify a port, therefore insert all signals from interface and auto-connect them

            # Get mapping for this interface
            if_mapping = get_interface_mapping(mapping[0]['if_name'])

            # Insert wires of the ports into the peripherals_wires list of the tester
            for port in interface_ports:
                # Create wire name based on mapping.
                wire_name = f"connect_{mapping[0]['corename']}_{mapping[0]['if_name']}_{port['name']}_to_{mapping[1]['corename']}_{mapping[1]['if_name']}_{if_mapping[port['name']]}"
                tester.peripheral_wires.append({'name':wire_name, 'n_bits':port['n_bits']})

                #TODO: Insert mapping between IO and PWIRE for mapping[0]

                #TODO: Insert mapping between IO and PWIRE for mapping[1]


        else:
            # Mapping configuration specified a port, therefore only insert singal for that port

            # Generate unique identifier for this conection based on the sum of bits
            # This identifier is required because they may be multiple wires of the same mapping but with different bits
            wire_identifier = 0 #FIXME: Generate unique id, maybe based on sum of bits?
            # Create wire name based on mapping and on unique identifier
            wire_name = f"connect_{mapping[0]['corename']}_{mapping[0]['if_name']}_{mapping[0]['port']}_to_{mapping[1]['corename']}_{mapping[1]['if_name']}_{mapping[0]['port']}_{wire_identifier}"
            #Get number of bits for this wire. If 'bits' was not specified, use the same size as the port of the peripheral
            if not mapping[0]['bits']:
                # Mapping did not specify bits, use the same size as the port (will map all bits of the port)
                n_bits = next(i for i in interface_ports if i['name'] == mapping[0]['port'])
            else:
                # Mapping specified bits, the with will be the sum of all the bits specified
                n_bits = sum(mapping[0]['bits'])
            # Insert wire of the ports into the peripherals_wires list of the tester
            tester.peripheral_wires.append({'name':wire_name, 'n_bits':n_bits})


            #TODO: Insert mapping between IO and PWIRE for mapping[0]

            #TODO: Insert mapping between IO and PWIRE for mapping[1]


    # Call setup function for the tester
    tester.main(build_dir=build_dir, gen_tex=False)
