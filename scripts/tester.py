#!/usr/bin/env python3
#
#    tester.py: tester related functions
#
from submodule_utils import import_setup
from ios import get_interface_mapping


#Given the io dictionary of ports, the port name (and size, and optional bit list) and a wire, it will map the selected bits of the port to the given wire.
#io_dict: dictionary where keys represent port names, values are the mappings
#port_name: name of the port to map
#port_size: size the port (if bits are not specified, this value is not used)
#port_bits: list of bits of the port that are being mapped to the wire. If list is empty it will map all the bits.
#           The order of bits in this list is important. The bits of the wire will always be filled in incremental order and will match the corresponding bit of the port given on this list following the list order. Example: The list [5,3] will map the port bit 5 to wire bit 0 and port bit 3 to wire bit 1.
#wire_name: name of the wire to connect the bits of the port to.
def map_IO_to_wire(io_dict, port_name, port_size, port_bits, wire_name):
    if port_name in io_dict and type(port_name) == str: raise Exception(f"Error: Peripheral port {port_name} has already been previously mapped!")
    if not port_bits:
        # Did not specify bits, connect all the entire port (all the bits)
        io_dict[port_name] = wire_name
    else:
        # Initialize array with port_size, all bits with 'None' value (not mapped)
        if port_name not in io_dict: io_dict[port_name] = [None for n in range(port_size)]
        # Map the selected bits to the corresponding wire bits
        # Each element in the bit list of this port will be a tuple containign the name of the wire to connect to and the bit of that wire.
        for wire_bit, bit in enumerate(port_bits):
            if io_dict[port_name][bit]: raise Exception(f"Error: Peripheral port {port_name} bit {bit} has already been previously mapped!")
            io_dict[port_name][bit] = (wire_name, wire_bit)

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

    # Add 'IO" attribute to every peripheral of tester
    for peripheral in tester_peripherals_list:
        peripheral['IO']={}

    #Handle peripheral portmap
    for map_idx, mapping in enumerate(peripheral_portmap):
        # List to store both items in this mamping
        mapping_items = [None, None]
        # Get tester block of peripheral in mapping[0]
        if mapping[0]['corename']: mapping_items[0]=next(i for i in tester_peripherals_list if i['name'] == mapping[0]['corename'])

        # Get tester block of peripheral in mapping[1]
        if mapping[1]['corename']: mapping_items[1]=next(i for i in tester_peripherals_list if i['name'] == mapping[1]['corename'])

        #Make sure we are not mapping two external interfaces
        if mapping_items == [None, None]: raise Exception(f"Error: {map_idx} Cannot map between two external interfaces!")

        # Store index if any of the entries is the external interface
        # Store -1 if we are not mapping to external interface
        mapping_external_interface = mapping_items.index(None) if None in mapping_items else -1

        # List of tester IOs from ports of this mapping
        tester_mapping_ios=[]
        # Add peripherals table to ios of tester
        tester.ios.append({'name': f"portmap_{map_idx}", 'descr':f"IOs for peripherals based on portmap index {map_idx}", 'ports': tester_mapping_ios})

        # Import module of one of the given core types (to access its IO)
        module = import_setup(tester.submodule_dirs[mapping_items[0]['type']])
        #Get ports of configured interface
        interface_ports=next(i['ports'] for i in module.ios if i['name'] == mapping[0]['if_name'])

        # Check if should insert one port or every port in the interface
        if not mapping[0]['port']:
            # Mapping configuration did not specify a port, therefore insert all signals from interface and auto-connect them
            #NOTE: currently mapping[1]['if_name'] is always assumed to be equal to mapping[0]['if_name']

            # Get mapping for this interface
            if_mapping = get_interface_mapping(mapping[0]['if_name'])

            # For every port: create wires and connect IO
            for port in interface_ports:
                if mapping_external_interface<0:
                    # Not mapped to external interface
                    # Create peripheral wire name based on mapping.
                    wire_name = f"connect_{mapping[0]['corename']}_{mapping[0]['if_name']}_{port['name']}_to_{mapping[1]['corename']}_{mapping[1]['if_name']}_{if_mapping[port['name']]}"
                    tester.peripheral_wires.append({'name':wire_name, 'n_bits':port['n_bits']})
                else:
                    #Mapped to external interface
                    #Add tester IO for this port
                    tester_mapping_ios.append(port)
                    #Wire name generated the same way as ios inserted in verilog
                    wire_name = f"portmap_{map_idx}_{port['name']}"

                #Insert mapping between IO and wire for mapping[0] (if its not external interface)
                if mapping_external_interface!=0: map_IO_to_wire(mapping_items[0]['IO'], port['name'], 0, [], wire_name)

                #Insert mapping between IO and wire for mapping[1] (if its not external interface)
                if mapping_external_interface!=1: map_IO_to_wire(mapping_items[1]['IO'], if_mapping[port['name']], 0, [], wire_name)

        else:
            # Mapping configuration specified a port, therefore only insert singal for that port

            port = next(i for i in interface_ports if i['name'] == mapping[0]['port'])
            #Get number of bits for this wire. If 'bits' was not specified, use the same size as the port of the peripheral
            if not mapping[0]['bits']:
                # Mapping did not specify bits, use the same size as the port (will map all bits of the port)
                n_bits = port['n_bits']
            else:
                # Mapping specified bits, the with will be the sum of all the bits specified
                n_bits = sum(mapping[0]['bits'])
                # Insert wire of the ports into the peripherals_wires list of the tester

            if mapping_external_interface<0:
                # Not mapped to external interface
                # Create wire name based on mapping
                wire_name = f"connect_{mapping[0]['corename']}_{mapping[0]['if_name']}_{mapping[0]['port']}_to_{mapping[1]['corename']}_{mapping[1]['if_name']}_{mapping[1]['port']}"
                tester.peripheral_wires.append({'name':wire_name, 'n_bits':n_bits})
            else:
                #Mapped to external interface
                #Add tester IO for this port
                tester_mapping_ios.append({'name':port['name'], 'type':port['type'], 'n_bits':n_bits, 'descr':port['descr']})
                #Wire name generated the same way as ios inserted in verilog
                wire_name = f"portmap_{map_idx}_{port['name']}"

            #Insert mapping between IO and wire for mapping[0] (if its not external interface)
            if mapping_external_interface!=0: map_IO_to_wire(mapping_items[0]['IO'], mapping[0]['port'], n_bits, mapping[0]['bits'], wire_name)

            #Insert mapping between IO and wire for mapping[1] (if its not external interface)
            if mapping_external_interface!=1: map_IO_to_wire(mapping_items[1]['IO'], mapping[1]['port'], n_bits, mapping[1]['bits'], wire_name)


    # Call setup function for the tester
    tester.main(build_dir=build_dir, gen_tex=False)
