import os

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()

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
    def _init_attributes(cls):
        """Init module attributes"""
        cls.submodules = [
            axil_s_port,
            axil_s_s_portmap,
            iob_m_port,
            iob_m_portmap,
            {"interface": "iob_wire"},
            {"interface": "clk_rst_s_s_portmap"},
            {"interface": "clk_rst_s_port"},
            iob_s_portmap,
        ]


if __name__ == "__main__":
    axil2iob.setup_as_top_module()
