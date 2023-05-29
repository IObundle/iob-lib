from iob_module import iob_module

class iob_s2f_sync(iob_module):
    name='iob_s2f_sync'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_s2f_sync.setup()        
        iob_counter.setup()        
        iob_reg_re.setup()        
