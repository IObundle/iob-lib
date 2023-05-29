from iob_module import iob_module

class iob_reg(iob_module):
    name='iob_reg'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_reg.setup()        
