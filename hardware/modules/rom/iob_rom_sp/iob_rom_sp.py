 
from iob_module import iob_module

class iob_rom_sp(iob_module):
    name='iob_rom_sp'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_rom_sp.setup()        
