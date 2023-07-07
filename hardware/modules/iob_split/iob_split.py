import os
import shutil

from iob_module import iob_module
from setup import setup
from iob_clkrst_portmap import iob_clkrst_portmap


class iob_split(iob_module):
    name = "iob_split"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup dependencies

        iob_clkrst_portmap.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
