import os
import shutil

from iob_module import iob_module
from iob_f2s_1bit_sync import iob_f2s_1bit_sync
from iob_reg import iob_reg

class iob_f2s_1bit_sync(iob_module):
    name='iob_f2s_1bit_sync'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_f2s_1bit_sync.v'), os.path.join(cls.build_dir, out_dir, 'iob_f2s_1bit_sync.v'))
        # Setup dependencies

        iob_f2s_1bit_sync.setup()        
        iob_reg.setup()        
