import os

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()


class altddion_in(iob_module):
    name = "altddion_in"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)


if __name__ == "__main__":
    altddion_in.setup_as_top_module()
