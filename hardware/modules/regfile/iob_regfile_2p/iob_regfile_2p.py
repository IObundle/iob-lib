import os

from iob_module import iob_module

from iob_ctls import iob_ctls


class iob_regfile_2p(iob_module):
    name = "iob_regfile_2p"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies
        iob_ctls.setup()

        iob_module.generate("clk_en_rst_port")
        iob_module.generate("clk_en_rst_portmap")
