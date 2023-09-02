import os

from iob_module import iob_module


class iob_demux2(iob_module):
    name = "iob_demux2"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)
