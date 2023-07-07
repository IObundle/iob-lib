import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg import iob_reg
from iob_clkenrst_portmap import iob_clkenrst_portmap


class iob_div_subshift(iob_module):
    name = "iob_div_subshift"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):

        # Verilog snippet files
        iob_clkenrst_portmap.setup()

        # Setup dependencies
        iob_reg.setup()

        super()._run_setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
