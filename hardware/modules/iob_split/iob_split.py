import os

from iob_module import iob_module

from iob_reg_re import iob_reg_re
from iob_mux import iob_mux
from iob_demux import iob_demux


class iob_split(iob_module):
    name = "iob_split"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "clk_rst_s_port"},
                {"interface": "clk_rst_s_s_portmap"},
                iob_reg_re,
                iob_demux,
                iob_mux,
            ]
        )
