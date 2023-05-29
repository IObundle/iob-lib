from iob_module import iob_module

class iob_reg_r(iob_module):
    name='iob_reg_r'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_reg_r.setup()        
        iob_reg.setup()        
