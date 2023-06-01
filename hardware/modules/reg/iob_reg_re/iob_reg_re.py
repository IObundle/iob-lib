import os
import shutil

from iob_module import iob_module
from iob_reg_r import iob_reg_r


class iob_reg_re(iob_module):
    name = "iob_reg_re"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(
            os.path.join(cls.setup_dir, "iob_reg_re.v"),
            os.path.join(cls.build_dir, out_dir, "iob_reg_re.v"),
        )
        # Setup dependencies

        iob_reg_r.setup()
