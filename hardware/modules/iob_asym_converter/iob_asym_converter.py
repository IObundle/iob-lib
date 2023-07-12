import os

from iob_module import iob_module

from iob_utils import iob_utils
from iob_reg import iob_reg
from iob_ram_2p import iob_ram_2p


class iob_asym_converter(iob_module):
    name = "iob_asym_converter"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        ''' Create submodules list with dependencies of this module
        '''
        super()._create_submodules_list([
            iob_utils,
            iob_reg,
            "clk_en_rst_portmap",
            "clk_en_rst_port",

            (iob_ram_2p, {"purpose": "simulation"}),
        ])
