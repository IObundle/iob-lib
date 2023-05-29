from iob_module import iob_module

class iob_piso_reg(iob_module):
    name='iob_piso_reg'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_piso_reg.setup()        
        iob_reg.setup()        
