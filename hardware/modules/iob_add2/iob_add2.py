import os

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()


class iob_add2(iob_module):
    name = "iob_add2"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)


if __name__ == "__main__":
    iob_add2.setup_as_top_module()
