import os
import shutil

from iob_module import iob_module

class iob_ram_dp(iob_module):
    name='iob_ram_dp'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob_ram_dp.v'), os.path.join(cls.build_dir, out_dir, 'iob_ram_dp.v'))
