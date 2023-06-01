import os
import shutil

from iob_module import iob_module
from iob_wire import iob_wire
from apb_s_port import apb_s_port
from iob_s_portmap import iob_s_portmap
from iob_reg import iob_reg


class apb2iob(iob_module):
    name = "apb2iob"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(
            os.path.join(cls.setup_dir, "apb2iob.v"),
            os.path.join(cls.build_dir, out_dir, "apb2iob.v"),
        )

        # Ensure sources of other purposes are deleted (except software)
        # Check that latest purpose is hardware
        if cls._setup_purpose[-1]=='hardware' and len(cls._setup_purpose)>1:
            # Purposes that have been setup previously
            for purpose in [x for x in cls._setup_purpose[:-1] if x!="software"]:
                # Delete sources for this purpose
                os.remove(os.path.join(cls.build_dir, cls.PURPOSE_DIRS[purpose], "apb2iob.v"))

        # Setup dependencies
        iob_wire.setup()
        apb_s_port.setup()
        iob_s_portmap.setup()
        iob_reg.setup()
