import os
import shutil

from iob_module import iob_module
from setup import setup


class altddion_out(iob_module):
    name = "altddion_out"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
