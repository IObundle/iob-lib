import os
import shutil

from iob_module import iob_module
from setup import setup


class iob_reg(iob_module):
    name = "iob_reg"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Verilog snippet files
        iob_module.generate("clk_en_rst_port")

        # Setup dependencies

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
