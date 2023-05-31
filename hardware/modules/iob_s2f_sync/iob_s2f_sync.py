import os
import shutil

from iob_module import iob_module
from iob_s2f_sync import iob_s2f_sync
from iob_counter import iob_counter
from iob_reg_re import iob_reg_re

class iob_s2f_sync(iob_module):
    name='iob_s2f_sync'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_s2f_sync.v'), os.path.join(cls.build_dir, out_dir, 'iob_s2f_sync.v'))
        # Setup dependencies

        iob_s2f_sync.setup()        
        iob_counter.setup()        
        iob_reg_re.setup()        
