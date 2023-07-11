import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_sync import iob_sync


class iob_s2f_sync(iob_module):
    name = "iob_s2f_sync"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _post_setup(cls):
        super()._post_setup()

        # Setup dependencies

        iob_sync.setup()
        iob_module.generate("clk_rst_port")
        iob_module.generate("clk_rst_portmap")

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
