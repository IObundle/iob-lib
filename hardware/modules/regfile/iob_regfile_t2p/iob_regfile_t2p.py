import os
import shutil

from iob_module import iob_module
from iob_regfile_t2p import iob_regfile_t2p
from iob_sync import iob_sync

class iob_regfile_t2p(iob_module):
    name='iob_regfile_t2p'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_regfile_t2p.v'), os.path.join(cls.build_dir, out_dir, 'iob_regfile_t2p.v'))
        # Setup dependencies

        iob_regfile_t2p.setup()        
        iob_sync.setup()        
