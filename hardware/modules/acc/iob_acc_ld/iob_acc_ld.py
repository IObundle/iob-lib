from iob_module import iob_module

class iob_acc_ld(iob_module):
    name='iob_acc_ld'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_acc_ld.setup()        
        iob_reg_re.setup()        
