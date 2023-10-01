import os

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg_re import iob_reg_re


class iob_counter(iob_module):
    name = "iob_counter"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.submodules = [
            {"interface": "clk_en_rst_s_port"},
            {"interface": "clk_en_rst_s_s_portmap"},
            iob_reg_re,
        ]


if __name__ == "__main__":
    iob_counter.setup_as_top_module()
