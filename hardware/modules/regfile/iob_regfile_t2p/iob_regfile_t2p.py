import os

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()

from iob_sync import iob_sync


class iob_regfile_t2p(iob_module):
    name = "iob_regfile_t2p"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.submodules = [
            iob_sync,
        ]


if __name__ == "__main__":
    iob_regfile_t2p.setup_as_top_module()
