from iob_module import iob_module

class axil2iob(iob_module):
    name='axil2iob'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        axil_s_port.setup()                
        axil_s_s_portmap.setup()        
        iob_m_port.setup()        
        iob_m_portmap.setup()        
        iob_wire.setup()        
        iob_s_portmap.setup()        

        axil2iob.setup()        
