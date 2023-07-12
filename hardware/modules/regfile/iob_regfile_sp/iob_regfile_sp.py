import os

from iob_module import iob_module

from iob_reg_re import iob_reg_re


class iob_regfile_sp(iob_module):
    name = "iob_regfile_sp"
    version = "V0.10"
    previous_version = "V0.09"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Verilog snippet files
        iob_module.generate("clk_en_rst_portmap")
        iob_module.generate("clk_en_rst_port")

        # Setup dependencies
        iob_reg_re.setup()

