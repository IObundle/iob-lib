import os

from iob_module import iob_module

from iob_sync import iob_sync


class iob_regfile_t2p(iob_module):
    name = "iob_regfile_t2p"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies

        iob_sync.setup()
