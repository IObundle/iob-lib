from iob_module import iob_module

class iob2axi(iob_module):
    name='iob2axi'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        m_axi_m_port.setup()                
        m_axi_write_m_port.setup()        
        m_axi_read_m_port.setup()        
        m_m_axi_write_portmap.setup()        
        m_m_axi_read_portmap.setup()        
                
        iob2axi.setup()        
        iob2axi_wr.setup()        
        iob2axi_rd.setup()        
        iob_fifo_sync.setup()        
