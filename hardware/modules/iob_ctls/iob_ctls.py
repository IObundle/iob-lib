import os
import shutil

from iob_module import iob_module
from iob_ctls import iob_ctls
from iob_reverse import iob_reverse

class iob_ctls(iob_module):
    name='iob_ctls'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_ctls.v'), os.path.join(cls.build_dir, out_dir, 'iob_ctls.v'))
        # Setup dependencies

        iob_ctls.setup()        
        iob_reverse.setup()        
