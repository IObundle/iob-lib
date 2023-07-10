import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg_re import iob_reg_re


class iob_counter(iob_module):
    name = "iob_counter"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup dependencies

        iob_reg_re.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
