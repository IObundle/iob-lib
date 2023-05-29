from iob_module import iob_module

class iob_acc(iob_module):
    name='iob_acc'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_acc.setup()        
        iob_reg_re.setup()        
