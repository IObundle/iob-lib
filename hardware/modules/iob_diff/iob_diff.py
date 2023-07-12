import os

from iob_module import iob_module

from iob_reg_r import iob_reg_r


class iob_diff(iob_module):
    name = "iob_diff"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        ''' Create submodules list with dependencies of this module
        '''
        super()._create_submodules_list([
            "clk_en_rst_portmap",
            "clk_en_rst_port",

            iob_reg_r,
        ])
