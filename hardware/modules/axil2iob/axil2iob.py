import os
import shutil

from iob_module import iob_module
from axil_s_port import axil_s_port
from axil_s_s_portmap import axil_s_s_portmap
from iob_m_port import iob_m_port
from iob_m_portmap import iob_m_portmap
from iob_wire import iob_wire
from iob_s_portmap import iob_s_portmap


class axil2iob(iob_module):
    name = "axil2iob"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(
            os.path.join(cls.setup_dir, "axil2iob.v"),
            os.path.join(cls.build_dir, out_dir, "axil2iob.v"),
        )
        # Setup dependencies

        axil_s_port.setup()
        axil_s_s_portmap.setup()
        iob_m_port.setup()
        iob_m_portmap.setup()
        iob_wire.setup()
        iob_s_portmap.setup()
