import os

from iob_module import iob_module


class iob_split2(iob_module):
    name = "iob_split2"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "clk_rst_s_s_portmap"},
                {"interface": "clk_rst_s_port"},
            ]
        )
