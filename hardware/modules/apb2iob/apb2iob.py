import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg import iob_reg


class apb2iob(iob_module):
    name = "apb2iob"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup dependencies
        iob_module.generate("iob_wire")
        iob_module.generate("apb_s_port")
        iob_module.generate("iob_s_portmap")
        iob_reg.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
