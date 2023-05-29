from iob_module import iob_module

class iob_sync(iob_module):
    name='iob_sync'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_sync.setup()        
        iob_reg.setup()        
