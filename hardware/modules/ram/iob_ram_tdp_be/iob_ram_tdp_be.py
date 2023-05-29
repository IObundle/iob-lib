from iob_module import iob_module

class iob_ram_tdp_be(iob_module):
    name='iob_ram_tdp_be'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_ram_tdp_be.setup()        
        iob_ram_tdp.setup()        
