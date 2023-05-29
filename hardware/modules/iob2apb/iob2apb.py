from iob_module import iob_module

class iob2apb(iob_module):
    name='iob2apb'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_s_port.setup()                
        iob_s_s_portmap.setup()        
        apb_m_port.setup()        
        iob_m_tb_wire.setup()        

        iob2apb.setup()        
        iob_reg.setup()        
