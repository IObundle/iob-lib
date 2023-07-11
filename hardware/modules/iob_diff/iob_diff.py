import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg_r import iob_reg_r


class iob_diff(iob_module):
    name = "iob_diff"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _post_setup(cls):
        super()._post_setup()

        # Setup dependencies
        iob_module.generate("clk_en_rst_portmap")
        iob_module.generate("clk_en_rst_port")

        iob_reg_r.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
