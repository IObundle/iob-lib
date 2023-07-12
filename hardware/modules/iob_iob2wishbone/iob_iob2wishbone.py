import os

from iob_module import iob_module

from iob_reg_re import iob_reg_re


class iob_iob2wishbone(iob_module):
    name = "iob_iob2wishbone"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies
        iob_module.generate("clk_en_rst_port")
        iob_module.generate("clk_en_rst_portmap")

        iob_reg_re.setup()
