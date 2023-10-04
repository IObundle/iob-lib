import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reverse import iob_reverse


class iob_prio_enc(iob_module):
    name = "iob_prio_enc"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.submodules = [
            iob_reverse,
        ]


if __name__ == "__main__":
    iob_prio_enc.setup_as_top_module()
