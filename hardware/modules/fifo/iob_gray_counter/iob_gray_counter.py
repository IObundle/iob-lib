from iob_module import iob_module

class iob_gray_counter(iob_module):
    name='iob_gray_counter'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_gray_counter.setup()        
        iob_reg_re.setup()        
