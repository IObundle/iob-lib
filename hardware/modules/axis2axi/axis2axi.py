from iob_module import iob_module

class axis2axi(iob_module):
    name='axis2axi'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        axi_m_port.setup()                
        axi_m_write_port.setup()        
        axi_m_read_port.setup()        
        axi_m_m_write_portmap.setup()        
        axi_m_m_read_portmap.setup()        
                
        axis2axi.setup()                
        axis2axi_in.setup()                
        axis2axi_out.setup()                
        iob_fifo_sync.setup()                
        iob_counter.setup()        
        iob_reg_r.setup()        
        iob_reg_re.setup()        
        iob_asym_converter.setup()        
                
        AxiDelay.setup(purpose="simulation")        
        axi_ram.setup(purpose="simulation")        
        iob_ram_t2p.setup(purpose="simulation")        
