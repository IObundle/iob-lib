import os
import shutil

from iob_module import iob_module
from setup import setup
from iob_reg_re import iob_reg_re


class iob_regfile_sp(iob_module):
    name = "iob_regfile_sp"
    version = "V0.10"
    previous_version = "V0.09"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        # Setup dependencies
        iob_reg_re.setup()

        cls._setup_confs()

        super()._run_setup()

        setup(cls, no_overlap=True)

    @classmethod
    def _setup_confs(cls):
        super()._setup_confs([])
