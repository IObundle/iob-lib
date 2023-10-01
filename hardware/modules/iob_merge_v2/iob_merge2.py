import os

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg import iob_reg
from iob_mux import iob_mux
from iob_demux import iob_demux


class iob_merge2(iob_module):
    name = "iob_merge2"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.submodules = [
            iob_reg,
            iob_mux,
            iob_demux,
        ]


if __name__ == "__main__":
    iob_merge2.setup_as_top_module()
