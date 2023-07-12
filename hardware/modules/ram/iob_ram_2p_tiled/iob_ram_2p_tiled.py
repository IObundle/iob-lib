import os

from iob_module import iob_module

from iob_ram_2p import iob_ram_2p


class iob_ram_2p_tiled(iob_module):
    name = "iob_ram_2p_tiled"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies

        iob_ram_2p.setup()
