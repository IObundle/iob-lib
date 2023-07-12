import os

from iob_module import iob_module

from iob_sync import iob_sync


class iob_s2f_sync(iob_module):
    name = "iob_s2f_sync"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies

        iob_sync.setup()
        iob_module.generate("clk_rst_port")
        iob_module.generate("clk_rst_portmap")
