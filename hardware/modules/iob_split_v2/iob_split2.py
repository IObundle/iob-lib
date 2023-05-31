import os
import shutil

from iob_module import iob_module
from iob_split2 import iob_split2
from iob_reg import iob_reg
from iob_mux import iob_mux
from iob_demux import iob_demux

class iob_split2(iob_module):
    name='iob_split2'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_split2.v'), os.path.join(cls.build_dir, out_dir, 'iob_split2.v'))
        # Setup dependencies

        iob_split2.setup()        
        iob_reg.setup()        
        iob_mux.setup()        
        iob_demux.setup()        
