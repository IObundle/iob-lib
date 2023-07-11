import os
import shutil

from iob_module import iob_module
from setup import setup

from axil_s_port import axil_s_port
from axil_s_s_portmap import axil_s_s_portmap
from iob_m_port import iob_m_port
from iob_m_portmap import iob_m_portmap
from iob_s_portmap import iob_s_portmap


class axil2iob(iob_module):
    name = "axil2iob"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _post_setup(cls):
        super()._post_setup()

        # Setup dependencies

        axil_s_port.setup()
        axil_s_s_portmap.setup()
        iob_m_port.setup()
        iob_m_portmap.setup()
        iob_module.generate("iob_wire")
        iob_module.generate("clk_rst_portmap")
        iob_module.generate("clk_rst_port")
        iob_s_portmap.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
