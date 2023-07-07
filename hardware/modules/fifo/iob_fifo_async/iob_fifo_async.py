import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_utils import iob_utils
from iob_gray_counter import iob_gray_counter
from iob_gray2bin import iob_gray2bin
from iob_sync import iob_sync
from iob_asym_converter import iob_asym_converter
from iob_ram_t2p import iob_ram_t2p


class iob_fifo_async(iob_module):
    name = "iob_fifo_async"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup dependencies

        iob_utils.setup()
        iob_gray_counter.setup()
        iob_gray2bin.setup()
        iob_sync.setup()
        iob_asym_converter.setup()

        iob_ram_t2p.setup(purpose="simulation")

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
