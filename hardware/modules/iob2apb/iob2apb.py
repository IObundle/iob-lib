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
        ''' Create submodules list with dependencies of this module
        '''
        super()._create_submodules_list([
            "iob_s_port",
            "iob_s_s_portmap",
            "apb_m_port",
            "iob_m_tb_wire",

            iob_reg,
            "clk_en_rst_portmap",
            "clk_en_rst_port",
        ])
