import os
import shutil

from iob_module import iob_module
from iob_fifo_sync import iob_fifo_sync
from iob_reg_r import iob_reg_r
from iob_reg import iob_reg
from iob_counter import iob_counter
from iob_asym_converter import iob_asym_converter
from iob_ram_2p import iob_ram_2p

class iob_fifo_sync(iob_module):
    name='iob_fifo_sync'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_fifo_sync.v'), os.path.join(cls.build_dir, out_dir, 'iob_fifo_sync.v'))
        # Setup dependencies

        iob_fifo_sync.setup()                
        iob_reg_r.setup()            
        iob_reg.setup()        
        iob_counter.setup()            
        iob_asym_converter.setup()        
            
        iob_ram_2p.setup(purpose="simulation")        
