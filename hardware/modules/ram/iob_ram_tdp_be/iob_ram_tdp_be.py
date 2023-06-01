import os
import shutil

from iob_module import iob_module
from iob_ram_tdp import iob_ram_tdp


class iob_ram_tdp_be(iob_module):
    name = "iob_ram_tdp_be"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(
            os.path.join(cls.setup_dir, "iob_ram_tdp_be.v"),
            os.path.join(cls.build_dir, out_dir, "iob_ram_tdp_be.v"),
        )
        # Setup dependencies

        iob_ram_tdp.setup()
