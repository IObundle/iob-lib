import os

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()


class iob2axil(iob_module):
    name = "iob2axil"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.submodules = [
            {"interface": "clk_rst_s_port"},
            {"interface": "iob_s_port"},
            {"interface": "iob_s_s_portmap"},
            {"interface": "axil_m_port"},
            {"interface": "axil_m_portmap"},
            {"interface": "iob_m_tb_wire"},
            {"interface": "axil_wire"},
        ]


if __name__ == "__main__":
    iob2axil.setup_as_top_module()
