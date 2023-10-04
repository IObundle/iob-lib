import os
import shutil

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()


class iob_asym_converter(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_asym_converter"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)


if __name__ == "__main__":
    iob_asym_converter.setup_as_top_module()
