import os

from iob_module import iob_module

from iob_reg import iob_reg


class iob2apb(iob_module):
    name = "iob2apb"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "iob_s_port"},
                {"interface": "iob_s_s_portmap"},
                {"interface": "apb_m_port"},
                {"interface": "iob_m_tb_wire"},
                iob_reg,
                {"interface": "clk_en_rst_portmap"},
                {"interface": "clk_en_rst_port"},
            ]
        )
