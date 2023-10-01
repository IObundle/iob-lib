import os

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()


class iob_split(iob_module):
    name = "iob_split"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.submodules = [
            {"interface": "clk_rst_s_s_portmap"},
            {"interface": "clk_rst_s_port"},
        ]


if __name__ == "__main__":
    iob_split.setup_as_top_module()
