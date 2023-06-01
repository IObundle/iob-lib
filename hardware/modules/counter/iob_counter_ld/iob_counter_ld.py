import os
import shutil

from iob_module import iob_module
from iob_reg_re import iob_reg_re

class iob_counter_ld(iob_module):
    name='iob_counter_ld'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_counter_ld.v'), os.path.join(cls.build_dir, out_dir, 'iob_counter_ld.v'))
        # Setup dependencies

        iob_reg_re.setup()        
