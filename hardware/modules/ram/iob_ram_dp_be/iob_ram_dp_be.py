from iob_module import iob_module

class iob_ram_dp_be(iob_module):
    name='iob_ram_dp_be'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_ram_dp_be.setup()        
        iob_ram_dp.setup()        
