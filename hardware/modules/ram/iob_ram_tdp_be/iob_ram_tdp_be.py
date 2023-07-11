import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_ram_tdp import iob_ram_tdp


class iob_ram_tdp_be(iob_module):
    name = "iob_ram_tdp_be"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _post_setup(cls):
        super()._post_setup()

        # Setup dependencies

        iob_ram_tdp.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
