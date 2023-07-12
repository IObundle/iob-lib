import os

from iob_module import iob_module


class iob_split(iob_module):
    name = "iob_split"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies

        iob_module.generate("clk_rst_portmap")
        iob_module.generate("clk_rst_port")
