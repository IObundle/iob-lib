import os

from iob_module import iob_module

from iob_reg_re import iob_reg_re


class iob_wishbone2iob(iob_module):
    name = "iob_wishbone2iob"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                "clk_en_rst_port",
                "clk_en_rst_portmap",
                iob_reg_re,
            ]
        )
