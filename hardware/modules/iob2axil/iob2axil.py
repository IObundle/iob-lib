import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_s_port import iob_s_port
from iob_s_s_portmap import iob_s_s_portmap
from axil_m_port import axil_m_port
from axil_m_portmap import axil_m_portmap
from iob_m_tb_wire import iob_m_tb_wire
from axil_wire import axil_wire


class iob2axil(iob_module):
    name = "iob2axil"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup dependencies

        iob_s_port.setup()
        iob_s_s_portmap.setup()
        axil_m_port.setup()
        axil_m_portmap.setup()
        iob_m_tb_wire.setup()
        axil_wire.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
