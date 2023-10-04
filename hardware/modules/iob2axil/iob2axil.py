import os

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()


class iob2axil(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob2axil"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
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
