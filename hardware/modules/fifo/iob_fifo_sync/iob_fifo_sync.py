import os

from iob_module import iob_module

from iob_reg_r import iob_reg_r
from iob_reg import iob_reg
from iob_counter import iob_counter
from iob_asym_converter import iob_asym_converter
from iob_ram_2p import iob_ram_2p
from iob_utils import iob_utils


class iob_fifo_sync(iob_module):
    name = "iob_fifo_sync"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies
        iob_module.generate("clk_en_rst_portmap")
        iob_module.generate("clk_en_rst_port")

        iob_reg_r.setup()
        iob_reg.setup()
        iob_counter.setup()
        iob_asym_converter.setup()
        iob_utils.setup()

        iob_ram_2p.setup(purpose="simulation")
