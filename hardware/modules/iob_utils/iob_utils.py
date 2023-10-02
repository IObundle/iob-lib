import os
import shutil

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()


class iob_utils(iob_module):
    name = "iob_utils"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)


if __name__ == "__main__":
    iob_utils.setup_as_top_module()
