#!/usr/bin/env python3

# Generates AXI4 and AXI4 Lite ports, port maps and signals
#
#   See "Usage" below
#

import sys

#bus constants
AXI_SIZE_W = '3'
AXI_BURST_W = '2'
AXI_LOCK_W = '2'
AXI_CACHE_W = '4'
AXI_PROT_W = '3'
AXI_QOS_W = '4'
AXI_RESP_W = '2'

table = []

axi_write=[ \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width':'AXI_ID_W',       'name':'axi_awid',    'default':'0', 'description':'Address write channel ID.'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width':'AXI_ADDR_W',     'name':'axi_awaddr',  'default':'0', 'description':'Address write channel address.'}, \
{'lite':0, 'signal':'`IOB_OUTPUT(', 'width':'AXI_LEN_W',      'name':'axi_awlen',   'default':'0', 'description':'Address write channel burst length.'}, \
{'lite':0, 'signal':'`IOB_OUTPUT(', 'width': AXI_SIZE_W,      'name':'axi_awsize',  'default':'2', 'description':'Address write channel burst size. This signal indicates the size of each transfer in the burst.'}, \
{'lite':0, 'signal':'`IOB_OUTPUT(', 'width': AXI_BURST_W,     'name':'axi_awburst', 'default':'1', 'description':'Address write channel burst type.'}, \
{'lite':0, 'signal':'`IOB_OUTPUT(', 'width': AXI_LOCK_W,      'name':'axi_awlock',  'default':'0', 'description':'Address write channel lock type.'}, \
{'lite':0, 'signal':'`IOB_OUTPUT(', 'width': AXI_CACHE_W,     'name':'axi_awcache', 'default':'2', 'description':'Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width': AXI_PROT_W,      'name':'axi_awprot',  'default':'2', 'description':'Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width': AXI_QOS_W,       'name':'axi_awqos',   'default':'0', 'description':'Address write channel quality of service.'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width':'1',              'name':'axi_awvalid', 'default':'0', 'description':'Address write channel valid.'}, \
{'lite':1, 'signal':'`IOB_INPUT(',  'width':'1',              'name':'axi_awready', 'default':'0', 'description':'Address write channel ready.'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width':'AXI_DATA_W',     'name':'axi_wdata',   'default':'0', 'description':'Write channel data.'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width':'(AXI_DATA_W/8)', 'name':'axi_wstrb',   'default':'0', 'description':'Write channel write strobe.'}, \
{'lite':0, 'signal':'`IOB_OUTPUT(', 'width':'1',              'name':'axi_wlast',   'default':'0', 'description':'Write channel last word flag.'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width':'1',              'name':'axi_wvalid',  'default':'0', 'description':'Write channel valid.'}, \
{'lite':1, 'signal':'`IOB_INPUT(',  'width':'1',              'name':'axi_wready',  'default':'0', 'description':'Write channel ready.'}, \
{'lite':1, 'signal':'`IOB_INPUT(',  'width':'AXI_ID_W',       'name':'axi_bid',     'default':'0', 'description':'Write response channel ID.'}, \
{'lite':1, 'signal':'`IOB_INPUT(',  'width': AXI_RESP_W,      'name':'axi_bresp',   'default':'0', 'description':'Write response channel response.'}, \
{'lite':1, 'signal':'`IOB_INPUT(',  'width':'1',              'name':'axi_bvalid',  'default':'0', 'description':'Write response channel valid.'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width':'1',              'name':'axi_bready',  'default':'0', 'description':'Write response channel ready.'} \
]

axi_read=[ \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width':'AXI_ID_W',       'name':'axi_arid',    'default':'0', 'description':'Address read channel ID.'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width':'AXI_ADDR_W',     'name':'axi_araddr',  'default':'0', 'description':'Address read channel address.'}, \
{'lite':0, 'signal':'`IOB_OUTPUT(', 'width':'AXI_LEN_W',      'name':'axi_arlen',   'default':'0', 'description':'Address read channel burst length.'}, \
{'lite':0, 'signal':'`IOB_OUTPUT(', 'width': AXI_SIZE_W,      'name':'axi_arsize',  'default':'2', 'description':'Address read channel burst size. This signal indicates the size of each transfer in the burst.'}, \
{'lite':0, 'signal':'`IOB_OUTPUT(', 'width': AXI_BURST_W,     'name':'axi_arburst', 'default':'1', 'description':'Address read channel burst type.'}, \
{'lite':0, 'signal':'`IOB_OUTPUT(', 'width': AXI_LOCK_W,      'name':'axi_arlock',  'default':'0', 'description':'Address read channel lock type.'}, \
{'lite':0, 'signal':'`IOB_OUTPUT(', 'width': AXI_CACHE_W,     'name':'axi_arcache', 'default':'2', 'description':'Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width': AXI_PROT_W,      'name':'axi_arprot',  'default':'2', 'description':'Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width': AXI_QOS_W,       'name':'axi_arqos',   'default':'0', 'description':'Address read channel quality of service.'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width':'1',              'name':'axi_arvalid', 'default':'0', 'description':'Address read channel valid.'}, \
{'lite':1, 'signal':'`IOB_INPUT(',  'width':'1',              'name':'axi_arready', 'default':'0', 'description':'Address read channel ready.'}, \
{'lite':1, 'signal':'`IOB_INPUT(',  'width':'AXI_ID_W',       'name':'axi_rid',     'default':'0', 'description':'Read channel ID.'}, \
{'lite':1, 'signal':'`IOB_INPUT(',  'width':'AXI_DATA_W',     'name':'axi_rdata',   'default':'0', 'description':'Read channel data.'}, \
{'lite':1, 'signal':'`IOB_INPUT(',  'width': AXI_RESP_W,      'name':'axi_rresp',   'default':'0', 'description':'Read channel response.'}, \
{'lite':0, 'signal':'`IOB_INPUT(',  'width':'1',              'name':'axi_rlast',   'default':'0', 'description':'Read channel last word.'}, \
{'lite':1, 'signal':'`IOB_INPUT(',  'width':'1',              'name':'axi_rvalid',  'default':'0', 'description':'Read channel valid.'}, \
{'lite':1, 'signal':'`IOB_OUTPUT(', 'width':'1',              'name':'axi_rready' , 'default':'0', 'description':'Read channel ready.'} \
]

#
# AXI-4 Full
#

def make_axi_write():
    bus=[]
    for i in range(len(axi_write)):
        bus.append(axi_write[i])
    return bus

def make_axi_read():
    bus=[]
    for i in range(len(axi_read)):
        bus.append(axi_read[i])
    return bus

def make_axi():
    return make_axi_write() + make_axi_read()

#
# AXI-4 Lite
#

def make_axil_write():
    bus=[]
    for i in range(len(axi_write)):
        if axi_write[i]['lite'] == 1:
            bus.append(axi_write[i])
            bus[-1]['name'] = bus[-1]['name'].replace('axi_', 'axil_')
            bus[-1]['width'] = bus[-1]['width'].replace('AXI_', 'AXIL_')
    return bus

def make_axil_read():
    bus=[]
    for i in range(len(axi_read)):
        if axi_read[i]['lite'] == 1:
            bus.append(axi_read[i])
            bus[-1]['name'] = bus[-1]['name'].replace('axi_', 'axil_')
            bus[-1]['width'] = bus[-1]['width'].replace('AXI_', 'AXIL_')
    return bus

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

def suffix(direction):
    if direction == '`IOB_INPUT(' or direction == '`IOB_VAR(':
        return '_i'
    elif direction == '`IOB_OUTPUT(' or direction == '`IOB_WIRE(':
        return '_o'
    else:
        print("ERROR: get_signal_suffix : invalid argument")
        quit()

#
# Port
#

def axi_m_port(prefix, fout):
    for i in range(len(table)):
        fout.write(' '+table[i]['signal']+prefix+table[i]['name']+suffix(table[i]['signal'])+', '+table[i]['width']+'), //'+table[i]['description']+'\n')
    
def axi_s_port(prefix, fout):
    for i in range(len(table)):
        fout.write(' '+reverse(table[i]['signal'])+prefix+table[i]['name']+suffix(reverse(table[i]['signal']))+', '+table[i]['width']+'), //'+table[i]['description']+'\n')

def axi_m_write_port(prefix, fout):
    axi_m_port(prefix, fout)
    
def axi_s_write_port(prefix, fout):
    axi_s_port(prefix, fout)

def axi_m_read_port(prefix, fout):
    axi_m_port(prefix, fout)
    
def axi_s_read_port(prefix, fout):
    axi_s_port(prefix, fout)

#
# Portmap
#

def axi_portmap(port_prefix, wire_prefix, fout):
    for i in range(len(table)):
        fout.write('.'+port_prefix+table[i]['name']+'('+wire_prefix+table[i]['name']+'), //'+table[i]['description']+'\n')

def axi_m_portmap(port_prefix, wire_prefix, fout):
    for i in range(len(table)):
        fout.write('.'+port_prefix+table[i]['name']+suffix(table[i]['signal'])+'('+wire_prefix+table[i]['name']+'), //'+table[i]['description']+'\n')

def axi_s_portmap(port_prefix, wire_prefix, fout):
    for i in range(len(table)):
        fout.write('.'+port_prefix+table[i]['name']+suffix(reverse(table[i]['signal']))+'('+wire_prefix+table[i]['name']+'), //'+table[i]['description']+'\n')

def axi_m_m_portmap(port_prefix, wire_prefix, fout):
    for i in range(len(table)):
        fout.write('.'+port_prefix+table[i]['name']+suffix(table[i]['signal'])+'('+wire_prefix+table[i]['name']+suffix(table[i]['signal'])+'), //'+table[i]['description']+'\n')

def axi_s_s_portmap(port_prefix, wire_prefix, fout):
    for i in range(len(table)):
        fout.write('.'+port_prefix+table[i]['name']+suffix(reverse(table[i]['signal']))+'('+wire_prefix+table[i]['name']+suffix(reverse(table[i]['signal']))+'), //'+table[i]['description']+'\n')

def axi_m_tb_portmap(port_prefix, wire_prefix, fout):
    axi_m_m_portmap(port_prefix, wire_prefix, fout)

def axi_s_tb_portmap(port_prefix, wire_prefix, fout):
    axi_s_s_portmap(port_prefix, wire_prefix, fout)

def axi_m_write_portmap(port_prefix, wire_prefix, fout):
    axi_m_portmap(port_prefix, wire_prefix, fout)

def axi_s_write_portmap(port_prefix, wire_prefix, fout):
    axi_s_portmap(port_prefix, wire_prefix, fout)

def axi_m_m_write_portmap(port_prefix, wire_prefix, fout):
    axi_m_m_portmap(port_prefix, wire_prefix, fout)

def axi_s_s_write_portmap(port_prefix, wire_prefix, fout):
    axi_s_s_portmap(port_prefix, wire_prefix, fout)

def axi_m_read_portmap(port_prefix, wire_prefix, fout):
    axi_m_portmap(port_prefix, wire_prefix, fout)

def axi_s_read_portmap(port_prefix, wire_prefix, fout):
    axi_s_portmap(port_prefix, wire_prefix, fout)

def axi_m_m_read_portmap(port_prefix, wire_prefix, fout):
    axi_m_m_portmap(port_prefix, wire_prefix, fout)

def axi_s_s_read_portmap(port_prefix, wire_prefix, fout):
    axi_s_s_portmap(port_prefix, wire_prefix, fout)

#
# Wire
#

def axi_wire(prefix, fout):
    for i in range(len(table)):
        fout.write('`IOB_WIRE('+prefix+table[i]['name']+', '+table[i]['width']+') //'+table[i]['description']+'\n')

def axi_m_tb_wire(prefix, fout):
    for i in range(len(table)):
        fout.write(tbsignal(table[i]['signal'])+prefix+table[i]['name']+suffix(tbsignal(table[i]['signal']))+', '+table[i]['width']+') //'+table[i]['description']+'\n')
    fout.write('\n')
    axi_m_tb_initial(prefix, fout)
    
def axi_s_tb_wire(prefix, fout):
    for i in range(len(table)):
        fout.write(tbsignal(reverse(table[i]['signal']))+prefix+table[i]['name']+suffix(tbsignal(reverse(table[i]['signal'])))+', '+table[i]['width']+') //'+table[i]['description']+'\n')
    fout.write('\n')
    axi_s_tb_initial(prefix, fout)

def axi_m_tb_initial(prefix, fout):
    fout.write('initial begin\n')
    for i in range(len(table)):
        if tbsignal(table[i]['signal']) == '`IOB_VAR(':
            fout.write('    '+prefix+table[i]['name']+suffix(tbsignal(table[i]['signal']))+' = '+table[i]['default']+';\n')
    fout.write('end\n')

def axi_s_tb_initial(prefix, fout):
    fout.write('initial begin\n')
    for i in range(len(table)):
        if tbsignal(reverse(table[i]['signal'])) == '`IOB_VAR(':
            fout.write('    '+prefix+table[i]['name']+suffix(tbsignal(reverse(table[i]['signal'])))+' = '+table[i]['default']+';\n')
    fout.write('end\n')

#
# Main
#
        
def main ():

    # parse command line arguments
    if len(sys.argv) < 2 or len(sys.argv) > 5:
        print(len(sys.argv))
        print("Usage: ./axi_gen.py type [file_prefix port_prefix wire_prefix]")
        print(len(sys.argv))
        print("       where type can defined as")
        print("            axi_m_port: axi full master port")
        print("            axi_s_port: axi full slave port")
        print("            axi_m_write_port: axi full master write port")
        print("            axi_s_write_port: axi full slave write port")
        print("            axi_m_read_port: axi full master read port")
        print("            axi_s_read_port: axi full slave read port")
        print("            axi_portmap: axi full portmap")
        print("            axi_m_portmap: axi full master portmap")
        print("            axi_s_portmap: axi full slave portmap")
        print("            axi_m_m_portmap: axi full master to master portmap")
        print("            axi_s_s_portmap: axi full slave to slave portmap")
        print("            axi_m_tb_portmap: axi full master to testbench portmap")
        print("            axi_s_tb_portmap: axi full slave to testbench portmap")
        print("            axi_m_write_portmap: axi full master write portmap")
        print("            axi_s_write_portmap: axi full slave write portmap")
        print("            axi_m_m_write_portmap: axi full master to master write portmap")
        print("            axi_s_s_write_portmap: axi full slave to slave write portmap")
        print("            axi_m_read_portmap: axi full master read portmap")
        print("            axi_s_read_portmap: axi full slave read portmap")
        print("            axi_m_m_read_portmap: axi full master to master read portmap")
        print("            axi_s_s_read_portmap: axi full slave to slave read portmap")
        print("            axi_wire: axi full wires for interconnection")
        print("            axi_m_tb_wire: axi full master wires for testbench")
        print("            axi_s_tb_wire: axi full slave wires for testbench")
        print("            axil_m_port: axi lite master port")
        print("            axil_s_port: axi lite slave port")
        print("            axil_m_write_port: axi lite master write port")
        print("            axil_s_write_port: axi lite slave write port")
        print("            axil_m_read_port: axi lite master read port")
        print("            axil_s_read_port: axi lite slave read port")
        print("            axil_portmap: axi lite portmap")
        print("            axil_m_portmap: axi lite master portmap")
        print("            axil_s_portmap: axi lite slave portmap")
        print("            axil_m_m_portmap: axi lite master to master portmap")
        print("            axil_s_s_portmap: axi lite slave to slave portmap")
        print("            axil_m_tb_portmap: axi lite master to testbench portmap")
        print("            axil_s_tb_portmap: axi lite slave to testbench portmap")
        print("            axil_m_write_portmap: axi lite master write portmap")
        print("            axil_s_write_portmap: axi lite slave write portmap")
        print("            axil_m_m_write_portmap: axi lite master to master write portmap")
        print("            axil_s_s_write_portmap: axi lite slave to slave write portmap")
        print("            axil_m_read_portmap: axi lite master read portmap")
        print("            axil_s_read_portmap: axi lite slave read portmap")
        print("            axil_m_m_read_portmap: axi lite master to master read portmap")
        print("            axil_s_s_read_portmap: axi lite slave to slave read portmap")
        print("            axil_wire: axi lite wires for interconnection")
        print("            axil_m_tb_wire: axi lite master wires for testbench")
        print("            axil_s_tb_wire: axi lite slave wires for testbench")
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
    
    if (typ.find("axi_m_write_")>=0): table = make_axi_write()
    elif (typ.find("axi_s_write_")>=0): table = make_axi_write()
    elif (typ.find("axi_m_read_")>=0): table = make_axi_read()
    elif (typ.find("axi_s_read_")>=0): table = make_axi_read()
    elif (typ.find("axi_read_")>=0): table = make_axi_read()
    elif (typ.find("axi_write_")>=0): table = make_axi_write()
    elif (typ.find("axi_")>=0): table = make_axi()
    elif (typ.find("axil_m_write_")>=0): table = make_axil_write()
    elif (typ.find("axil_s_write_")>=0): table = make_axil_write()
    elif (typ.find("axil_m_read_")>=0): table = make_axil_read()
    elif (typ.find("axil_s_read_")>=0): table = make_axil_read()
    elif (typ.find("axil_read_")>=0): table = make_axi_read()
    elif (typ.find("axil_write_")>=0): table = make_axi_write()
    elif (typ.find("axil_")>=0): table = make_axil()

    port_name = typ
    
    #write pragma for doc production
    if (port_name.find("port")+1 and not port_name.find("portmap")+1):
        fout.write('  //START_IO_TABLE '+port_prefix+port_name+'\n')

    # call function func to generate .vh file
    func_name = port_name.replace("axil_","axi_")
    if (port_name.find("portmap")+1):
        eval(func_name+"('"+port_prefix+"','"+wire_prefix+"', fout)")
    else:
        eval(func_name+"('"+port_prefix+"', fout)")

    fout.close()

if __name__ == "__main__" : main ()
