import os
import shutil

from iob_module import iob_module
from iob_counter import iob_counter
from iob_reg import iob_reg

class iob_sipo_reg(iob_module):
    name='iob_sipo_reg'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_sipo_reg.v'), os.path.join(cls.build_dir, out_dir, 'iob_sipo_reg.v'))
        # Setup dependencies

        iob_counter.setup()        
        iob_reg.setup()        
