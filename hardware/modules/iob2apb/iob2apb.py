import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg import iob_reg
from iob_clkenrst_portmap import iob_clkenrst_portmap


class iob2apb(iob_module):
    name = "iob2apb"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup dependencies

        iob_module.generate("iob_s_port")
        iob_module.generate("iob_s_s_portmap")
        iob_module.generate("apb_m_port")
        iob_module.generate("iob_m_tb_wire")

        iob_reg.setup()
        iob_clkenrst_portmap.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
