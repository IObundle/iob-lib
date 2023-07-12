import os

from iob_module import iob_module

from iob_reg_r import iob_reg_r


class iob_reg_re(iob_module):
    name = "iob_reg_re"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Verilog snippet files
        iob_module.generate("clk_en_rst_portmap")
        iob_module.generate("clk_en_rst_port")

        # Setup dependencies
        iob_reg_r.setup()
