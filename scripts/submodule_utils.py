#!/usr/bin/env python3
# Library with useful functions to manage submodules and peripherals

import sys
import subprocess
import os
import re
import math
import importlib
import if_gen

# List of reserved signals
# These signals are known by the python scripts and are always connected using the matching Verilog the string.
reserved_signals = \
{
'clk_i':'.clk_i(clk_i)',
'cke_i':'.cke_i(cke_i)',
'en_i':'.en_i(en_i)',
'rst_i':'.rst_i(rst_i)',
'reset':'.reset(rst_i)',
'arst_i':'.arst_i(arst_i)',
'iob_avalid':'.iob_avalid(slaves_req[`avalid(`/*<InstanceName>*/)])',
'iob_addr':'.iob_addr(slaves_req[`address(`/*<InstanceName>*/,`/*<SwregFilename>*/_ADDR_W)])',
'iob_wdata':'.iob_wdata(slaves_req[`wdata(`/*<InstanceName>*/)])',
'iob_wstrb':'.iob_wstrb(slaves_req[`wstrb(`/*<InstanceName>*/)])',
'iob_rdata':'.iob_rdata(slaves_resp[`rdata(`/*<InstanceName>*/)])',
'iob_ready':'.iob_ready(slaves_resp[`ready(`/*<InstanceName>*/)])',
'iob_rvalid':'.iob_rvalid(slaves_resp[`rvalid(`/*<InstanceName>*/)])',
'trap':'.trap(trap[0])',
'm_axi_awid':'.m_axi_awid    (m_axi_awid[0:0])',
'm_axi_awaddr':'.m_axi_awaddr  (m_axi_awaddr[`DDR_ADDR_W-1:0])',
'm_axi_awlen':'.m_axi_awlen   (m_axi_awlen[7:0])',
'm_axi_awsize':'.m_axi_awsize  (m_axi_awsize[2:0])',
'm_axi_awburst':'.m_axi_awburst (m_axi_awburst[1:0])',
'm_axi_awlock':'.m_axi_awlock  (m_axi_awlock[0:0])',
'm_axi_awcache':'.m_axi_awcache (m_axi_awcache[3:0])',
'm_axi_awprot':'.m_axi_awprot  (m_axi_awprot[2:0])',
'm_axi_awqos':'.m_axi_awqos   (m_axi_awqos[3:0])',
'm_axi_awvalid':'.m_axi_awvalid (m_axi_awvalid[0:0])',
'm_axi_awready':'.m_axi_awready (m_axi_awready[0:0])',
'm_axi_wdata':'.m_axi_wdata   (m_axi_wdata[`DATA_W-1:0])',
'm_axi_wstrb':'.m_axi_wstrb   (m_axi_wstrb[`DATA_W/8-1:0])',
'm_axi_wlast':'.m_axi_wlast   (m_axi_wlast[0:0])',
'm_axi_wvalid':'.m_axi_wvalid  (m_axi_wvalid[0:0])',
'm_axi_wready':'.m_axi_wready  (m_axi_wready[0:0])',
'm_axi_bid':'.m_axi_bid     (m_axi_bid[0:0])',
'm_axi_bresp':'.m_axi_bresp   (m_axi_bresp[1:0])',
'm_axi_bvalid':'.m_axi_bvalid  (m_axi_bvalid[0:0])',
'm_axi_bready':'.m_axi_bready  (m_axi_bready[0:0])',
'm_axi_arid':'.m_axi_arid    (m_axi_arid[0:0])',
'm_axi_araddr':'.m_axi_araddr  (m_axi_araddr[`DDR_ADDR_W-1:0])',
'm_axi_arlen':'.m_axi_arlen   (m_axi_arlen[7:0])',
'm_axi_arsize':'.m_axi_arsize  (m_axi_arsize[2:0])',
'm_axi_arburst':'.m_axi_arburst (m_axi_arburst[1:0])',
'm_axi_arlock':'.m_axi_arlock  (m_axi_arlock[0:0])',
'm_axi_arcache':'.m_axi_arcache (m_axi_arcache[3:0])',
'm_axi_arprot':'.m_axi_arprot  (m_axi_arprot[2:0])',
'm_axi_arqos':'.m_axi_arqos   (m_axi_arqos[3:0])',
'm_axi_arvalid':'.m_axi_arvalid (m_axi_arvalid[0:0])',
'm_axi_arready':'.m_axi_arready (m_axi_arready[0:0])',
'm_axi_rid':'.m_axi_rid     (m_axi_rid[0:0])',
'm_axi_rdata':'.m_axi_rdata   (m_axi_rdata[`DATA_W-1:0])',
'm_axi_rresp':'.m_axi_rresp   (m_axi_rresp[1:0])',
'm_axi_rlast':'.m_axi_rlast   (m_axi_rlast[0:0])',
'm_axi_rvalid':'.m_axi_rvalid  (m_axi_rvalid[0:0])',
'm_axi_rready':'.m_axi_rready  (m_axi_rready[0:0])',
}

# Import the <corename>_setup.py from the given core directory
def import_setup(setup_dir):
    #Find <corename>_setup.py file
    for x in os.listdir(setup_dir):
        if x.endswith("_setup.py"):
            filename = x
            break
    if 'filename' not in vars():
        raise FileNotFoundError(f"Could not find a *_setup.py file in {setup_dir}")
    #Import <corename>_setup.py
    spec = importlib.util.spec_from_file_location("core_module", setup_dir+"/"+filename)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    return module

# Return short port type string based on given types: "input", "output" and "inout"
# Maps "I", "O" and "IO" to "input", "output" and "inout", respectively.
def get_short_port_type(port_type):
    if port_type == "input":
        return "I"
    elif port_type == "output":
        return "O"
    else:
        return "IO"


# Get path to build directory of directory
# Parameter: directory: path to core directory
# Returns: string with path to build directory
def get_build_lib(directory):
    # pattern: <any_string>_V[number].[number]
    # example: iob_CORE_V1.23
    build_dir_pattern = re.compile("(.*?)_V[0-9]+.[0-9]+")

    dir_entries = os.scandir(directory)
    for d in dir_entries:
        if d.is_dir() and build_dir_pattern.match(d.name):
            return d.path
    return ""


# Return submodule_dirs dictionary from iob_*_setup.py in given directory
def get_submodule_directories(root_dir):
    module=import_setup(root_dir)
    return module.submodule_dirs

# Replaces a verilog parameter in a string with its value.
# The value is determined based on default value and the instance parameters given (that may override the default)
# Arguments: 
#   string_with_parameter: string with parameter that will be replaced. Example: "SIZE_PARAMETER+2"
#   params_list: list of dictionaries, each of them describes a parameter and contains its default value
#   instance_parameters: dictionary of parameters for this peripheral instance that may override default value
#                        The keys are the parameters names, the values are the parameters values
# Returns: 
#   String with parameter replaced. Example: "input [32:0]"
def replaceByParameterValue(string_with_parameter, params_list, instance_parameters):
    param_to_replace = None
    #Find parameter name
    for parameter in params_list:
        if parameter['name'] in string_with_parameter:
            param_to_replace=parameter
            break

    #Return unmodified string if there is no parameter in string
    if not param_to_replace:
        return string_with_parameter;

    #If parameter should be overriden
    if(param_to_replace['name'] in instance_parameters):
        #Replace parameter in string with value from instance parameter to override
        return string_with_parameter.replace(param_to_replace['name'],instance_parameters[param_to_replace['name']])
    else:
        #Replace parameter in string with default value 
        return string_with_parameter.replace(param_to_replace['name'],param_to_replace['val'])

# Parameter: PERIPHERALS string defined in config.mk
# Returns dictionary with amount of instances for each peripheral
# Also returns dictionary with verilog parameters for each of those instance
# instances_amount example: {'corename': numberOfInstances, 'anothercorename': numberOfInstances}
# instances_parameters example: {'corename': [['instance1parameter1','instance1parameter2'],['instance2parameter1','instance2parameter2']]}
def get_peripherals(peripherals_str):
    peripherals = peripherals_str.split()

    instances_amount = {}
    instances_parameters = {}
    # Count how many instances to create of each type of peripheral
    for i in peripherals:
        i = i.split("[") # Split corename and parameters
        # Initialize corename in dictionary 
        if i[0] not in instances_amount:
            instances_amount[i[0]]=0
            instances_parameters[i[0]]=[]
        # Insert parameters of this instance (if there are any)
        if len(i) > 1:
            i[1] = i[1].strip("]") # Delete final "]" from parameter list
            instances_parameters[i[0]].append(i[1].split(","))
        else:
            instances_parameters[i[0]].append([])
        # Increment amount of instances
        instances_amount[i[0]]+=1

    #print(instances_amount, file = sys.stderr) #Debug
    #print(instances_parameters, file = sys.stderr) #Debug
    return instances_amount, instances_parameters

# A virtual file object with a port list. It has a write() method to extract information from if_gen.py signals.
# Can be used to create virtual file objects with a write() method that parses the if_gen.py port string.
class if_gen_hack_list:
    def __init__(self):
        self.port_list=[]

    def write(self, port_string):
        #Parse written string
        port = re.search("^\s*((?:input)|(?:output))\s+\[([^:]+)-1:0\]\s+([^,]+), \/\/(.*)$", verilog_lines[i])
        #Append port to port dictionary
        self.port_list.append({'name':port.group(3), 'type':get_short_port_type(port.group(1)), 'n_bits':port.group(2), 'descr':port.group(4)})

def if_gen_interface(interface_name):
    if_gen.create_signal_table(interface_name)
    # Create a virtual file object
    virtual_file_obj = if_gen_hack_list()
    # Tell if_gen to write ports in virtual file object
    if_gen.write_vh_contents(interface_name, '', '', virtual_file_obj)
    # Extract port list from virtual file object
    return virtual_file_obj.port_list

# Given ios object for the module, extract the list of ports.
# Returns a list of dictionaries that describe each port.
# Example return list: 
#[ {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral clock input"},
#  {'name':"rst_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral reset input"} ]
def get_module_io(ios):
    module_signals = []
    for table in ios:
        # Check if this table is a standard interface (from if_gen.py)
        if table['name'] in if_gen.interfaces:
            # Interface is standard, generate ports
            module_signals.extend(if_gen_interface(table['name']))
        else:
            # Interface is not standard, read ports
            module_signals.extend(table['ports'])
    return module_signals

# Given lines read from the verilog file with a module declaration
# this function returns the parameters of that module. 
# The return value is a dictionary, where the key is the 
# parameter name and the value is the default value assigned to the parameter.
def get_module_parameters(verilog_lines):
    module_start = 0
    #Find module declaration
    for line in verilog_lines:
        module_start += 1
        if "module " in line:
            break #Found module declaration

    parameter_list_start = module_start
    #Find module parameter list start 
    for i in range(module_start, len(verilog_lines)):
        parameter_list_start += 1
        if verilog_lines[i].replace(" ", "").startswith("#("):
            break #Found parameter list start

    module_parameters = {}
    #Get parameters of this module
    for i in range(parameter_list_start, len(verilog_lines)):
        #Ignore comments and empty lines
        if not verilog_lines[i].strip() or verilog_lines[i].lstrip().startswith("//"):
            continue
        if ")" in verilog_lines[i]:
            break #Found end of parameter list

        # Parse parameter
        parameter = re.search("^\s*parameter\s+([^=\s]+)\s*=\s*([^\s,]+),?", verilog_lines[i])
        if parameter is not None:
            # Store parameter in dictionary with format: module_parameters[parametername] = "default value"
                module_parameters[parameter.group(1)]=parameter.group(2)

    return module_parameters

# Filter out non reserved signals from a given list (not stored in string reserved_signals)
# Example signal_list: 
#[ {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral clock input"},
#  {'name':"custom_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral custom input"} ]
# Return of this example:
#[ {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral clock input"} ]
def get_reserved_signals(signal_list):
    return_list = []
    for signal in signal_list:
        if signal['name'] in reserved_signals:
            return_list.append(signal)
    return return_list

def get_reserved_signal_connection(signal_name, instace_name, swreg_filename):
    signal_connection = reserved_signals[signal_name]
    return re.sub("\/\*<InstanceName>\*\/",instace_name,
            re.sub("\/\*<SwregFilename>\*\/",swreg_filename,
            signal_connection))

# Filter out reserved signals from a given list (stored in string reserved_signals)
# Example signal_list: 
#[ {'name':"clk_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral clock input"},
#  {'name':"custom_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral custom input"} ]
# Return of this example:
#[ {'name':"custom_i", 'type':"I", 'n_bits':'1', 'descr':"Peripheral custom input"} ]
def get_pio_signals(signal_list):
    return_list = []
    for signal in signal_list:
        if signal['name'] not in reserved_signals:
            return_list.append(signal)
    return return_list

# Get port list, parameter list and top module name for each type of peripheral in a list of instances of peripherals
# port_list, params_list, and top_list are dictionaries where their key is the name of the type of peripheral
# The value of port_list is a list of ports for the given type of peripheral
# The value of params_list is a list of parameters for the given type of peripheral
# The value of top_list is the top name of the given type of peripheral
def get_peripherals_ports_params_top(peripherals_list, submodule_dirs):
    port_list = {}
    params_list = {}
    top_list = {}
    for instance in peripherals_list:
        if instance['type'] not in port_list:
            # Import <corename>_setup.py module
            module = import_setup(submodule_dirs[instance['type']])
            # Append module IO, parameters, and top name
            port_list[instance['type']]=get_module_io(module.ios)
            params_list[instance['type']]=list(i for i in module.confs if i['type'] == 'P')
            top_list[instance['type']]=module.meta['name']
    return port_list, params_list, top_list

# Find index of word in array with multiple strings
def find_idx(lines, word):
    for idx, i in enumerate(lines):
        if word in i:
            break
    return idx+1

#Creates list of defines of peripheral instances with sequential numbers
#Returns list of tuples. One tuple for each peripheral instance with its name and value.
def get_periphs_id(peripherals_str):
    instances_amount, _ = get_peripherals(peripherals_str)
    peripherals_list = []
    j=0
    for corename in instances_amount:
        for i in range(instances_amount[corename]):
            peripherals_list.append((corename+str(i),str(j)))
            j = j + 1
    return peripherals_list

# Given a list of dictionaries representing each peripheral instance
# Return list of dictionaries representing macros of each peripheral instance with their ID assigned
def get_periphs_id_as_macros(peripherals_list):
    macro_list = []
    for idx, instance in enumerate(peripherals_list):
        macro_list.append({'name':instance['name'], 'type':'M', 'val':str(idx), 'min':'0', 'max':'NA', 'descr':f"ID of {instance['name']} peripheral"})
    return macro_list

# Return amount of system peripherals
def get_n_periphs(peripherals_list):
    return str(len(peripherals_list))

# Return bus width required to address all peripherals
def get_n_periphs_w(peripherals_list):
    i=len(peripherals_list)
    if not i:
        return str(0)
    else:
        return str(math.ceil(math.log(i,2)))


##########################################################
# Functions to run when this script gets called directly #
##########################################################
def print_instances(peripherals_str):
    instances_amount, _ = get_peripherals(peripherals_str)
    for corename in instances_amount:
        for i in range(instances_amount[corename]):
            print(corename+str(i), end=" ")

def print_peripherals(peripherals_str):
    instances_amount, _ = get_peripherals(peripherals_str)
    for i in instances_amount:
        print(i, end=" ")

def print_nslaves(peripherals_str):
    print(get_n_periphs(peripherals_str), end="")

def print_nslaves_w(peripherals_str):
    print(get_n_periphs_w(peripherals_str), end="")

#Print list of peripherals without parameters and duplicates
def remove_duplicates_and_params(peripherals_str):
    peripherals = peripherals_str.split()
    #Remove parameters from peripherals
    for i in range(len(peripherals)):
        peripherals[i] = peripherals[i].split("[")[0]
    #Remove peripheral duplicates
    peripherals = list(set(peripherals))
    #Print list of peripherals
    for p in peripherals:
        print(p, end=" ")

#Print list of peripheral instances with ID assigned
def print_peripheral_defines(defmacro, peripherals_str):
    peripherals_list = get_periphs_id(peripherals_str)
    for instance in peripherals_list:
        print(defmacro+instance[0]+"="+instance[1], end=" ")

if __name__ == "__main__":
    # Parse arguments
    if sys.argv[1] == "get_peripherals":
        if len(sys.argv)<3:
            print("Usage: {} get_peripherals <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_peripherals(sys.argv[2])
    elif sys.argv[1] == "get_instances":
        if len(sys.argv)<3:
            print("Usage: {} get_instances <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_instances(sys.argv[2])
    elif sys.argv[1] == "get_n_periphs":
        if len(sys.argv)<3:
            print("Usage: {} get_n_periphs <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_nslaves(sys.argv[2])
    elif sys.argv[1] == "get_n_periphs_w":
        if len(sys.argv)<3:
            print("Usage: {} get_n_periphs_w <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_nslaves_w(sys.argv[2])
    elif sys.argv[1] == "remove_duplicates_and_params":
        if len(sys.argv)<3:
            print("Usage: {} remove_duplicates_and_params <peripherals>\n".format(sys.argv[0]))
            exit(-1)
        remove_duplicates_and_params(sys.argv[2])
    elif sys.argv[1] == "get_periphs_id":
        if len(sys.argv)<3:
            print("Usage: {} get_periphs_id <peripherals> <optional:defmacro>\n".format(sys.argv[0]))
            exit(-1)
        if len(sys.argv)<4:
            print_peripheral_defines("",sys.argv[2])
        else:
            print_peripheral_defines(sys.argv[3],sys.argv[2])
    else:
        print("Unknown command.\nUsage: {} <command> <parameters>\n Commands: get_peripherals get_instances get_n_periphs get_n_periphs_w get_periphs_id print_peripheral_defines".format(sys.argv[0]))
        exit(-1)
