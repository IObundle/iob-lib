import os
import shutil

from iob_module import iob_module
from iob_fifo_async import iob_fifo_async
from iob_gray2bin import iob_gray2bin
from iob_sync import iob_sync
from iob_asym_converter import iob_asym_converter
from iob_ram_t2p import iob_ram_t2p

class iob_fifo_async(iob_module):
    name='iob_fifo_async'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_fifo_async.v'), os.path.join(cls.build_dir, out_dir, 'iob_fifo_async.v'))
        # Setup dependencies

        iob_fifo_async.setup()                
        iob_gray_counter.setup()            
        iob_gray2bin.setup()        
        iob_sync.setup()        
        iob_asym_converter.setup()        

        iob_ram_t2p.setup(purpose="simulation")        
