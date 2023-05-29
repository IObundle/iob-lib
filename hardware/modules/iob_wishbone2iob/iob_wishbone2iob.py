from iob_module import iob_module

class iob_wishbone2iob(iob_module):
    name='iob_wishbone2iob'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_wishbone2iob.setup()        
        iob_reg_re.setup()        
