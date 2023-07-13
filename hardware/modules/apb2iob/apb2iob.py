import os

from iob_module import iob_module

from iob_reg import iob_reg


class apb2iob(iob_module):
    name = "apb2iob"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                "iob_wire",
                "apb_s_port",
                "iob_s_portmap",
                "clk_en_rst_port",
                "clk_en_rst_portmap",
                iob_reg,
            ]
        )
