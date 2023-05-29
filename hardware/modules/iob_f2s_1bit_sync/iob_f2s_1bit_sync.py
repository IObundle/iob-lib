from iob_module import iob_module

class iob_f2s_1bit_sync(iob_module):
    name='iob_f2s_1bit_sync'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_f2s_1bit_sync.setup()        
        iob_reg.setup()        
