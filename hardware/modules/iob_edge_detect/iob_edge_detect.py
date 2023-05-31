import os
import shutil

from iob_module import iob_module
from iob_edge_detect import iob_edge_detect
from iob_reg import iob_reg

class iob_edge_detect(iob_module):
    name='iob_edge_detect'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_edge_detect.v'), os.path.join(cls.build_dir, out_dir, 'iob_edge_detect.v'))
        # Setup dependencies

        iob_edge_detect.setup()        
        iob_reg.setup()        
