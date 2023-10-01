import os

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()

from iob_ram_tdp import iob_ram_tdp


class iob_ram_tdp_be(iob_module):
    name = "iob_ram_tdp_be"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.submodules = [
            iob_ram_tdp,
        ]


if __name__ == "__main__":
    iob_ram_tdp_be.setup_as_top_module()
