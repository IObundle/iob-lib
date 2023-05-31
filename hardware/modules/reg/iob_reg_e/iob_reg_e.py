import os
import shutil

from iob_module import iob_module
from iob_reg_e import iob_reg_e
from iob_reg import iob_reg

class iob_reg_e(iob_module):
    name='iob_reg_e'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_reg_e.v'), os.path.join(cls.build_dir, out_dir, 'iob_reg_e.v'))
        # Setup dependencies

        iob_reg_e.setup()        
        iob_reg.setup()        
