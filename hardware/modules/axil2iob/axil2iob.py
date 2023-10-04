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
from iob_reg_re import iob_reg_re


class axil2iob(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "axil2iob"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            axil_s_port,
            axil_s_s_portmap,
            iob_m_port,
            iob_m_portmap,
            {"interface": "iob_wire"},
            {"interface": "clk_rst_s_s_portmap"},
            {"interface": "clk_rst_s_port"},
            iob_s_portmap,
            iob_reg_re,
        ]


if __name__ == "__main__":
    axil2iob.setup_as_top_module()
