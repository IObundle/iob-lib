import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg_re import iob_reg_re
from iob_clkenrst_portmap import iob_clkenrst_portmap
from iob_clkenrst_port import iob_clkenrst_port


class iob_acc_ld(iob_module):
    name = "iob_acc_ld"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Verilog snippet files
        iob_clkenrst_portmap.setup()
        iob_clkenrst_port.setup()

        # Setup dependencies
        iob_reg_re.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
