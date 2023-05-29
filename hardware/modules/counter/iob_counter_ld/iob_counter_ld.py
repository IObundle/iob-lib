from iob_module import iob_module

class iob_counter_ld(iob_module):
    name='iob_counter_ld'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_counter_ld.setup()        
        iob_reg_re.setup()        
