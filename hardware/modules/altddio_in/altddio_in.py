import os
import shutil

from iob_module import iob_module
from setup import setup


class altddion_in(iob_module):
    name = "altddion_in"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _post_setup(cls):
        super()._post_setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
