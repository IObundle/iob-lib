import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_fifo_sync import iob_fifo_sync
from iob_counter import iob_counter
from iob_reg_r import iob_reg_r
from iob_reg_re import iob_reg_re
from iob_asym_converter import iob_asym_converter
from axi_ram import axi_ram
from iob_ram_t2p import iob_ram_t2p


class axis2axi(iob_module):
    name = "axis2axi"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup dependencies

        iob_module.generate("axi_m_port")
        iob_module.generate("axi_m_write_port")
        iob_module.generate("axi_m_read_port")
        iob_module.generate("axi_m_m_write_portmap")
        iob_module.generate("axi_m_m_read_portmap")

        iob_fifo_sync.setup()
        iob_counter.setup()
        iob_reg_r.setup()
        iob_reg_re.setup()
        iob_asym_converter.setup()

        axi_ram.setup(purpose="simulation")
        iob_ram_t2p.setup(purpose="simulation")

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
