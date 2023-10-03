import os

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg_r import iob_reg_r
from iob_reg import iob_reg
from iob_counter import iob_counter
from iob_asym_converter import iob_asym_converter
from iob_ram_2p import iob_ram_2p
from iob_utils import iob_utils
from iob_fifo_sync import iob_fifo_sync


class iob_shift_reg(iob_module):
    name = "iob_shift_reg"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.submodules = [
            {"interface": "clk_en_rst_s_s_portmap"},
            {"interface": "clk_en_rst_s_port"},
            iob_reg_r,
            iob_reg,
            iob_counter,
            iob_asym_converter,
            iob_utils,
            iob_fifo_sync,
            (iob_ram_2p, {"purpose": "simulation"}),
        ]


if __name__ == "__main__":
    iob_shift_reg.setup_as_top_module()
