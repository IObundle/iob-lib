from iob_module import iob_module

class iob_sipo_reg(iob_module):
    name='iob_sipo_reg'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_sipo_reg.setup()        
        iob_counter.setup()        
        iob_reg.setup()        
