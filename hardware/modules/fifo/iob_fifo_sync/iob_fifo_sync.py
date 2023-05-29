from iob_module import iob_module

class iob_fifo_sync(iob_module):
    name='iob_fifo_sync'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_fifo_sync.setup()                
        iob_reg_r.setup()            
        iob_reg.setup()        
        iob_counter.setup()            
        iob_asym_converter.setup()        
            
        iob_ram_2p.setup(purpose="simulation")        
