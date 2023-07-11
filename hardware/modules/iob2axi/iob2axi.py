import os
import shutil

from iob_module import iob_module
from setup import setup

from m_axi_m_port import m_axi_m_port
from m_axi_write_m_port import m_axi_write_m_port
from m_axi_read_m_port import m_axi_read_m_port
from m_m_axi_write_portmap import m_m_axi_write_portmap
from m_m_axi_read_portmap import m_m_axi_read_portmap
from iob2axi_wr import iob2axi_wr
from iob2axi_rd import iob2axi_rd
from iob_fifo_sync import iob_fifo_sync


class iob2axi(iob_module):
    name = "iob2axi"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _post_setup(cls):
        super()._post_setup()

        # Setup dependencies
        m_axi_m_port.setup()
        m_axi_write_m_port.setup()
        m_axi_read_m_port.setup()
        m_m_axi_write_portmap.setup()
        m_m_axi_read_portmap.setup()
        iob_module.generate("clk_rst_port")

        iob2axi_wr.setup()
        iob2axi_rd.setup()
        iob_fifo_sync.setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
