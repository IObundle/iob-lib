import os

from iob_module import iob_module

from iob_counter import iob_counter


class iob_modcnt(iob_module):
    name = "iob_modcnt"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies
        iob_module.generate("clk_en_rst_port")
        iob_module.generate("clk_en_rst_portmap")

        iob_modcnt.setup()
        iob_counter.setup()
