import os

from iob_module import iob_module

from axil_s_port import axil_s_port
from axil_s_s_portmap import axil_s_s_portmap
from iob_m_port import iob_m_port
from iob_m_portmap import iob_m_portmap
from iob_s_portmap import iob_s_portmap


class axil2iob(iob_module):
    name = "axil2iob"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        ''' Create submodules list with dependencies of this module
        '''
        super()._create_submodules_list([
            axil_s_port,
            axil_s_s_portmap,
            iob_m_port,
            iob_m_portmap,
            "iob_wire",
            "clk_rst_portmap",
            "clk_rst_port",
            iob_s_portmap,
        ])
