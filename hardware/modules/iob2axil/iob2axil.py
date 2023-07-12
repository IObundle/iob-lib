import os

from iob_module import iob_module

from iob_s_port import iob_s_port
from iob_s_s_portmap import iob_s_s_portmap
from axil_m_port import axil_m_port
from axil_m_portmap import axil_m_portmap
from iob_m_tb_wire import iob_m_tb_wire
from axil_wire import axil_wire


class iob2axil(iob_module):
    name = "iob2axil"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        ''' Create submodules list with dependencies of this module
        '''
        super()._create_submodules_list([
            iob_s_port,
            iob_s_s_portmap,
            axil_m_port,
            axil_m_portmap,
            iob_m_tb_wire,
            axil_wire,

            "clk_rst_port",
        ])
