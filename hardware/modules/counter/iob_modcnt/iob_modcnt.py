import os
import shutil

from iob_module import iob_module
from iob_counter import iob_counter

class iob_modcnt(iob_module):
    name='iob_modcnt'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_modcnt.v'), os.path.join(cls.build_dir, out_dir, 'iob_modcnt.v'))
        # Setup dependencies

        iob_modcnt.setup()        
        iob_counter.setup()        
