import os
import shutil

from iob_module import iob_module
from iob_reg_re import iob_reg_re


class iob_wishbone2iob(iob_module):
    name = "iob_wishbone2iob"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(
            os.path.join(cls.setup_dir, "iob_wishbone2iob.v"),
            os.path.join(cls.build_dir, out_dir, "iob_wishbone2iob.v"),
        )
        # Setup dependencies

        iob_reg_re.setup()
