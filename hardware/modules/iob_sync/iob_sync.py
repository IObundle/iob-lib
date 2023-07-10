import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg import iob_reg
from iob_clkrst_port import iob_clkrst_port


class iob_sync(iob_module):
    name = "iob_sync"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup dependencies

        iob_clkrst_port.setup()
        iob_reg.setup()
        iob_clkrst_port.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
