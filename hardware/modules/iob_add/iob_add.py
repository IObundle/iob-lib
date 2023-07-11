import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_add2 import iob_add2


class iob_add(iob_module):
    name = "iob_add"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _post_setup(cls):
        super()._post_setup()

        # Verilog snippet files
        iob_add2.setup()

        # Setup dependencies

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
