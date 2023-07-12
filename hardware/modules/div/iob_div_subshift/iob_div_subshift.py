import os

from iob_module import iob_module

from iob_reg import iob_reg


class iob_div_subshift(iob_module):
    name = "iob_div_subshift"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Verilog snippet files
        iob_module.generate("clk_en_rst_portmap")
        iob_module.generate("clk_en_rst_port")

        # Setup dependencies
        iob_reg.setup()
