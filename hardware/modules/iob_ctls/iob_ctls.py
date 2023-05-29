from iob_module import iob_module

class iob_ctls(iob_module):
    name='iob_ctls'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_ctls.setup()        
        iob_reverse.setup()        
