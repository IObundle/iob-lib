import os

from iob_module import iob_module

from iob_reg import iob_reg


class iob_edge_detect(iob_module):
    name = "iob_edge_detect"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies

        iob_reg.setup()
        iob_module.generate("clk_en_rst_portmap")
        iob_module.generate("clk_en_rst_port")
