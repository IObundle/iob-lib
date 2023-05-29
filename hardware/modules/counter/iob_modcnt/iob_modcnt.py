from iob_module import iob_module

class iob_modcnt(iob_module):
    name='iob_modcnt'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_modcnt.setup()        
        iob_counter.setup()        
