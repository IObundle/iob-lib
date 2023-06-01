import os
import shutil

from iob_module import iob_module
from iob_reg_re import iob_reg_re

class iob_gray_counter(iob_module):
    name='iob_gray_counter'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_gray_counter.v'), os.path.join(cls.build_dir, out_dir, 'iob_gray_counter.v'))
        # Setup dependencies

        iob_gray_counter.setup()        
        iob_reg_re.setup()        
