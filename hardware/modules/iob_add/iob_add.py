import os

from iob_module import iob_module

from iob_add2 import iob_add2


class iob_add(iob_module):
    name = "iob_add"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Verilog snippet files
        iob_add2.setup()

        # Setup dependencies
