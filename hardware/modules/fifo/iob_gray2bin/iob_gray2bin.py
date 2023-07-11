import os
import shutil

from iob_module import iob_module
from setup import setup


class iob_gray2bin(iob_module):
    name = "iob_gray2bin"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _post_setup(cls):
        super()._post_setup()

        # Setup dependencies

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
