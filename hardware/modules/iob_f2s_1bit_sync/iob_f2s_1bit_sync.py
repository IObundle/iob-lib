import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg import iob_reg


class iob_f2s_1bit_sync(iob_module):
    name = "iob_f2s_1bit_sync"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _post_setup(cls):
        super()._post_setup()

        # Setup dependencies

        iob_reg.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
