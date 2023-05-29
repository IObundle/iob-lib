from iob_module import iob_module

class iob2axil(iob_module):
    name='iob2axil'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_s_port.setup()                
        iob_s_s_portmap.setup()        
        axil_m_port.setup()        
        axil_m_portmap.setup()        
        iob_m_tb_wire.setup()        
        axil_wire.setup()        
            
        iob2axil.setup()        
