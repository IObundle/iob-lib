from iob_module import iob_module

class iob_asym_converter(iob_module):
    name='iob_asym_converter'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_asym_converter.setup()        
        iob_reg.setup()        

        iob_ram_2p.setup(purpose="simulation")        
