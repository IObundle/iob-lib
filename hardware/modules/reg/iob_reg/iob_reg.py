import os

from iob_module import iob_module


class iob_reg(iob_module):
    name = "iob_reg"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Verilog snippet files
        iob_module.generate("clk_en_rst_port")

        # Setup dependencies
