import os
import shutil

from iob_module import iob_module
from setup import setup
from iob_reg_re import iob_reg_re


class iob_regfile_sp(iob_module):
    name = "iob_regfile_sp"
    version = "V0.10"
    previous_version = "V0.09"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        # Setup dependencies
        iob_reg_re.setup()

        super()._run_setup()

        if cls.is_top_module:
            # Setup flows of this core using LIB setup function
            setup(cls, disable_file_gen=True)
