import os
import shutil

from iob_module import iob_module
from setup import setup


class iob_iobuf(iob_module):
    name = "iob_iobuf"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Verilog snippet files

        # Setup dependencies

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
