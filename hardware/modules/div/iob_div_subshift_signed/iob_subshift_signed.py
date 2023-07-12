import os

from iob_module import iob_module

from iob_reg import iob_reg


class iob_div_subshift_signed(iob_module):
    name = "iob_div_subshift_signed"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
        # Verilog snippet files
        iob_module.generate("clk_en_rst_portmap")

        # Setup dependencies
        iob_reg.setup()

        super()._specific_setup()
