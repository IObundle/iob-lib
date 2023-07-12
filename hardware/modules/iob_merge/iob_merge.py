import os

from iob_module import iob_module

from iob_reg_e import iob_reg_e
from iob_mux import iob_mux
from iob_demux import iob_demux


class iob_merge(iob_module):
    name = "iob_merge"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies
        iob_reg_e.setup()
        iob_mux.setup()
        iob_demux.setup()

        iob_module.generate("clk_en_rst_portmap")
        iob_module.generate("clk_en_rst_port")
