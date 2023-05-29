from iob_module import iob_module

class iob_diff(iob_module):
    name='iob_diff'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_diff.setup()        
        iob_reg_r.setup()        
