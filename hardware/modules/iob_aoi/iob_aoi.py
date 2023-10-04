import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_and import iob_and
from iob_or import iob_or
from iob_inv import iob_inv


class iob_aoi(iob_module):
    name = "iob_aoi"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.submodules = [
            iob_and,
            iob_or,
            iob_inv,
        ]


if __name__ == "__main__":
    iob_aoi.setup_as_top_module()
