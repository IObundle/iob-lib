import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg_re import iob_reg_re


class iob_iob2wishbone(iob_module):
    name = "iob_iob2wishbone"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _post_setup(cls):
        super()._post_setup()

        # Setup dependencies
        iob_module.generate("clk_en_rst_port")
        iob_module.generate("clk_en_rst_portmap")

        iob_reg_re.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
