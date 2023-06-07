import os
import shutil

from iob_module import iob_module


class iob_str(iob_module):
    name = "iob_str"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()
        
        # Setup dependencies


    # Copy sources of this module to the build directory
    @classmethod
    def _copy_srcs(cls):
        out_dir = cls.get_purpose_dir(cls._setup_purpose[-1])
        # Copy source to build directory
        shutil.copyfile(
            os.path.join(cls.setup_dir, "iob_str.h"),
            os.path.join(cls.build_dir, out_dir, "iob_str.h"),
        )
        shutil.copyfile(
            os.path.join(cls.setup_dir, "iob_str.c"),
            os.path.join(cls.build_dir, out_dir, "iob_str.c"),
        )
