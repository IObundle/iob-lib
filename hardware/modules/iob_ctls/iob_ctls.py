import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reverse import iob_reverse
from iob_prio_enc import iob_prio_enc


class iob_ctls(iob_module):
    name = "iob_ctls"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup dependencies

        iob_reverse.setup()
        iob_prio_enc.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
