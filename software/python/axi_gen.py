#!/usr/bin/env python3

# Generates AXI4 and AXI$ Lite ports, port maps and signals:
#
# ./axi_gen.py type [file_prefix port_prefix wire_prefix]")
#
#     type = [axi_port_m|axi_port_s|axi_portmap|axi_wire|axi_m_tb|axi_s_tb]
#

import sys

#bus constants
AXI_ID_W = '1'
AXI_LEN_W = '8'
AXI_SIZE_W = '3'
AXI_BURST_W = '2'
AXI_LOCK_W = '1'
AXI_CACHE_W = '4'
AXI_PROT_W = '3'
AXI_QOS_W = '4'
AXI_RESP_W = '2'

table = []

#
# AXI-4 Full
#

def make_axi_write():
    return [ \
['`IOB_OUTPUT(', AXI_ID_W,        'axi_awid',    'Address write channel ID'], \
['`IOB_OUTPUT(', 'AXI_ADDR_W',    'axi_awaddr',  'Address write channel address'], \
['`IOB_OUTPUT(', AXI_LEN_W,       'axi_awlen',   'Address write channel burst length'], \
['`IOB_OUTPUT(', AXI_SIZE_W,      'axi_awsize',  'Address write channel burst size. This signal indicates the size of each transfer in the burst'], \
['`IOB_OUTPUT(', AXI_BURST_W,     'axi_awburst', 'Address write channel burst type'], \
['`IOB_OUTPUT(', AXI_LOCK_W,      'axi_awlock',  'Address write channel lock type'], \
['`IOB_OUTPUT(', AXI_CACHE_W,     'axi_awcache', 'Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).'], \
['`IOB_OUTPUT(', AXI_PROT_W,      'axi_awprot',  'Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).'], \
['`IOB_OUTPUT(', AXI_QOS_W,       'axi_awqos',   'Address write channel quality of service'], \
['`IOB_OUTPUT(', '1',             'axi_awvalid', 'Address write channel valid'], \
['`IOB_INPUT(',  '1',             'axi_awready', 'Address write channel ready'], \
['`IOB_OUTPUT(', AXI_ID_W,        'axi_wid',     'Write channel ID'], \
['`IOB_OUTPUT(', 'AXI_DATA_W',    'axi_wdata',   'Write channel data'], \
['`IOB_OUTPUT(', '(AXI_DATA_W/8)', 'axi_wstrb',   'Write channel write strobe'], \
['`IOB_OUTPUT(', '1',             'axi_wlast',   'Write channel last word flag'], \
['`IOB_OUTPUT(', '1',             'axi_wvalid',  'Write channel valid'], \
['`IOB_INPUT(',  '1',             'axi_wready',  'Write channel ready'], \
['`IOB_INPUT(',  AXI_ID_W,        'axi_bid',     'Write response channel ID'], \
['`IOB_INPUT(',  AXI_RESP_W,      'axi_bresp',   'Write response channel response'], \
['`IOB_INPUT(',  '1',             'axi_bvalid',  'Write response channel valid'], \
['`IOB_OUTPUT(', '1',             'axi_bready',  'Write response channel ready'] \
]

def make_axi_read():
    return [ \
['`IOB_OUTPUT(', AXI_ID_W,        'axi_arid',    'Address read channel ID'], \
['`IOB_OUTPUT(', 'AXI_ADDR_W',    'axi_araddr',  'Address read channel address'], \
['`IOB_OUTPUT(', AXI_LEN_W,       'axi_arlen',   'Address read channel burst length'], \
['`IOB_OUTPUT(', AXI_SIZE_W,      'axi_arsize',  'Address read channel burst size. This signal indicates the size of each transfer in the burst'], \
['`IOB_OUTPUT(', AXI_BURST_W,     'axi_arburst', 'Address read channel burst type'], \
['`IOB_OUTPUT(', AXI_LOCK_W,      'axi_arlock',  'Address read channel lock type'], \
['`IOB_OUTPUT(', AXI_CACHE_W,     'axi_arcache', 'Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).'], \
['`IOB_OUTPUT(', AXI_PROT_W,      'axi_arprot',  'Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).'], \
['`IOB_OUTPUT(', AXI_QOS_W,       'axi_arqos',   'Address read channel quality of service'], \
['`IOB_OUTPUT(', '1',             'axi_arvalid', 'Address read channel valid'], \
['`IOB_INPUT(',  '1',             'axi_arready', 'Address read channel ready'], \
['`IOB_INPUT(',  AXI_ID_W,        'axi_rid',     'Read channel ID'], \
['`IOB_INPUT(', 'AXI_DATA_W',     'axi_rdata',   'Read channel data'], \
['`IOB_INPUT(',  AXI_RESP_W,      'axi_rresp',   'Read channel response'], \
['`IOB_INPUT(',  '1',             'axi_rlast',   'Read channel last word'], \
['`IOB_INPUT(',  '1',             'axi_rvalid',  'Read channel valid' ], \
['`IOB_OUTPUT(', '1',             'axi_rready' , 'Read channel ready'] \
]

def make_axi():
    return make_axi_write() + make_axi_read()

#
# AXI-4 Lite
#

def make_axil_write():
    return [ \
['`IOB_OUTPUT(', AXI_ID_W,         'axil_awid',    'Address write channel ID'], \
['`IOB_OUTPUT(', 'AXIL_ADDR_W',    'axil_awaddr',  'Address write channel address'], \
['`IOB_OUTPUT(', AXI_PROT_W,       'axil_awprot',  'Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).'], \
['`IOB_OUTPUT(', AXI_QOS_W,        'axil_awqos',   'Address write channel quality of service'], \
['`IOB_OUTPUT(', '1',              'axil_awvalid', 'Address write channel valid'], \
['`IOB_INPUT(',  '1',              'axil_awready', 'Address write channel ready'], \
['`IOB_OUTPUT(', AXI_ID_W,         'axil_wid',     'Write channel ID'], \
['`IOB_OUTPUT(', 'AXIL_DATA_W',    'axil_wdata',   'Write channel data'], \
['`IOB_OUTPUT(', '(AXIL_DATA_W/8)','axil_wstrb',   'Write channel write strobe'], \
['`IOB_OUTPUT(', '1',              'axil_wvalid',  'Write channel valid'], \
['`IOB_INPUT(',  '1',              'axil_wready',  'Write channel ready'], \
['`IOB_INPUT(',  AXI_ID_W,         'axil_bid',     'Write response channel ID'], \
['`IOB_INPUT(',  AXI_RESP_W,       'axil_bresp',   'Write response channel response'], \
['`IOB_INPUT(',  '1',              'axil_bvalid',  'Write response channel valid'], \
['`IOB_OUTPUT(', '1',              'axil_bready',  'Write response channel ready'] \
]

def make_axil_read(AXIL_ADDR_W, AXIL_DATA_W):
    return [ \
['`IOB_OUTPUT(', AXI_ID_W,         'axil_arid',    'Address read channel ID'], \
['`IOB_OUTPUT(', 'AXIL_ADDR_W',    'axil_araddr',  'Address read channel address'], \
['`IOB_OUTPUT(', AXI_PROT_W,       'axil_arprot',  'Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).'], \
['`IOB_OUTPUT(', AXI_QOS_W,        'axil_arqos',   'Address read channel quality of service'], \
['`IOB_OUTPUT(', '1',              'axil_arvalid', 'Address read channel valid'], \
['`IOB_INPUT(',  '1',              'axil_arready', 'Address read channel ready'], \
['`IOB_INPUT(',  AXI_ID_W,         'axil_rid',     'Read channel ID'], \
['`IOB_INPUT(',  'AXIL_DATA_W',    'axil_rdata',   'Read channel data'], \
['`IOB_INPUT(',  AXI_RESP_W,       'axil_rresp',   'Read channel response'], \
['`IOB_INPUT(',  '1',              'axil_rvalid',  'Read channel valid' ], \
['`IOB_OUTPUT(', '1',              'axil_rready',  'Read channel ready'] \
]

def make_axil():
    return make_axil_write() + make_axil_read()


def reverse(direction):
    if direction == '`IOB_INPUT(':
        return '`IOB_OUTPUT('
    elif direction == '`IOB_OUTPUT(':
        return '`IOB_INPUT('
    else:
        print("ERROR: reverse_direction : invalid argument")
        quit()
        
def tbsignal(direction):
    if direction == '`IOB_INPUT(':
        return '`IOB_WIRE('
    elif direction == '`IOB_OUTPUT(':
        return '`IOB_VAR('
    else:
        print("ERROR: tb_reciprocal : invalid argument")
        quit()

#
# Port
#

def axi_m_port(prefix, fout):
    for i in range(len(table)):
        fout.write(' '+table[i][0]+prefix+table[i][2]+', '+table[i][1]+'), //'+table[i][3]+'\n')
    
def axi_s_port(prefix, fout):
    for i in range(len(table)):
        fout.write(' '+reverse(table[i][0])+prefix+table[i][2]+', '+table[i][1]+'), //'+table[i][3]+'\n')

#
# Portmap
#

def axi_portmap(port_prefix, wire_prefix, fout):
    for i in range(len(table)):
        fout.write('.'+port_prefix+table[i][2]+'('+wire_prefix+table[i][2]+'), //'+table[i][3]+'\n')

#
# Wire
#

def axi_m_tb(prefix, fout):
    for i in range(len(table)):
        fout.write(tbsignal(table[i][0])+prefix+table[i][2]+', '+table[i][1]+') //'+table[i][3]+'\n')
    
def axi_s_tb(prefix, fout):
    for i in range(len(table)):
        fout.write(tbsignal(reverse(table[i][0]))+prefix+table[i][2]+', '+table[i][1]+') //'+table[i][3]+'\n')

def axi_wire(prefix, fout):
    for i in range(len(table)):
        fout.write('`IOB_WIRE('+prefix+table[i][2]+', '+table[i][1]+') //'+table[i][3]+'\n')

#
# Main
#
        
def main ():

    # parse command line arguments
    if len(sys.argv) < 2 or len(sys.argv) > 4:
        print(len(sys.argv))
        print("Usage: ./axi_gen.py type [file_prefix port_prefix wire_prefix]")
        print(len(sys.argv))
        print("       where type={axi_m_port|axi_s_port|axi_portmap|axi_m_tb|axi_s_tb|axi_wire}")
        quit()

    #axi bus type
    typ = sys.argv[1]

    #port and wire prefix
    file_prefix = ''
    port_prefix = ''
    wire_prefix = ''
    if len(sys.argv) > 2: file_prefix = sys.argv[2]
    if len(sys.argv) > 3: port_prefix = sys.argv[3]
    if len(sys.argv) > 4: wire_prefix = sys.argv[4]

    # open output .vh file
    fout = open (file_prefix+typ+".vh", 'w')

    # make AXI bus

    global table
    
    if (typ.find("axi_write_")>=0): table = make_axi_write()
    elif (typ.find("axi_read_")>=0): table = make_axi_read()
    elif (typ.find("axi_")>=0): table = make_axi()
    elif (typ.find("axil_write_")>=0): table = make_axil_write()
    elif (typ.find("axil_read_")>=0): table = make_axil_read()
    elif (typ.find("axil_")>=0): table = make_axil()

    port_name = typ.replace("write_","").replace("read_","")

    if (port_name.find("m_port")+1 or port_name.find("s_port")+1):
        fout.write('  //START_IO_TABLE '+port_prefix+port_name+'\n')

    # call function func to generate .vh file
    func_name = port_name.replace("axil_","axi_")
    if (port_name.find("portmap")+1): eval(func_name+"('"+port_prefix+"','"+wire_prefix+"', fout)")
    else: eval(func_name+"('"+port_prefix+"', fout)")

if __name__ == "__main__" : main ()
