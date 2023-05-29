from iob_module import iob_module

class iob_reg_e(iob_module):
    name='iob_reg_e'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_reg_e.setup()        
        iob_reg.setup()        
