import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg import iob_reg
from iob_mux import iob_mux
from iob_demux import iob_demux


class iob_merge2(iob_module):
    name = "iob_merge2"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup dependencies

        iob_reg.setup()
        iob_mux.setup()
        iob_demux.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
