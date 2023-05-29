from iob_module import iob_module

class iob_fifo_async(iob_module):
    name='iob_fifo_async'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_fifo_async.setup()                
        iob_gray_counter.setup()            
        iob_gray2bin.setup()        
        iob_sync.setup()        
        iob_asym_converter.setup()        

        iob_ram_t2p.setup(purpose="simulation")        
