from iob_module import iob_module

class iob_ram_2p_tiled(iob_module):
    name='iob_ram_2p_tiled'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_ram_2p_tiled.setup()        
        iob_ram_2p.setup()        
