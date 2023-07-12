import os

from iob_module import iob_module

from iob_reg import iob_reg
from iob_mux import iob_mux
from iob_demux import iob_demux


class iob_merge2(iob_module):
    name = "iob_merge2"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies

        iob_reg.setup()
        iob_mux.setup()
        iob_demux.setup()
