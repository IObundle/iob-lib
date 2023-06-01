import os
import shutil

from iob_module import iob_module
from iob_reg_e import iob_reg_e
from iob_mux import iob_mux
from iob_demux import iob_demux


class iob_merge(iob_module):
    name = "iob_merge"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(
            os.path.join(cls.setup_dir, "iob_merge.v"),
            os.path.join(cls.build_dir, out_dir, "iob_merge.v"),
        )

        # Ensure sources of other purposes are deleted (except software)
        # Check that latest purpose is hardware
        if cls._setup_purpose[-1]=='hardware' and len(cls._setup_purpose)>1:
            # Purposes that have been setup previously
            for purpose in [x for x in cls._setup_purpose[:-1] if x!="software"]:
                # Delete sources for this purpose
                os.remove(os.path.join(cls.build_dir, cls.PURPOSE_DIRS[purpose], "iob_merge.v"))

        # Setup dependencies
        iob_reg_e.setup()
        iob_mux.setup()
        iob_demux.setup()
