import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg_r import iob_reg_r


class iob_reg_re(iob_module):
    name = "iob_reg_re"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Verilog snippet files
        iob_module.generate("clk_en_rst_portmap")
        iob_module.generate("clk_en_rst_port")

        # Setup dependencies
        iob_reg_r.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
