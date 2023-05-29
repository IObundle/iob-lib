from iob_module import iob_module

class iob_iob2wishbone(iob_module):
    name='iob_iob2wishbone'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_iob2wishbone.setup()        
        iob_reg_re.setup()        
