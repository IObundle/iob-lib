import os
import shutil

from iob_module import iob_module
from setup import setup


class iob_ram_2p(iob_module):
    name = "iob_ram_2p"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        if cls.is_top_module:
            # Setup flows of this core using LIB setup function
            setup(cls, disable_file_gen=True)

            # Copy testbench if this is the top module
            shutil.copyfile(
                os.path.join(cls.setup_dir, "iob_ram_2p_tb.v"),
                os.path.join(
                    cls.build_dir, "hardware/simulation/src", "iob_ram_2p_tb.v"
                ),
            )

    # Copy sources of this module to the build directory
    @classmethod
    def _copy_srcs(cls):
        out_dir = cls.get_purpose_dir(cls._setup_purpose[-1])
        # Copy source to build directory
        shutil.copyfile(
            os.path.join(cls.setup_dir, "iob_ram_2p.v"),
            os.path.join(cls.build_dir, out_dir, "iob_ram_2p.v"),
        )

        # Ensure sources of other purposes are deleted (except software)
        # Check that latest purpose is hardware
        if cls._setup_purpose[-1] == "hardware" and len(cls._setup_purpose) > 1:
            # Purposes that have been setup previously
            for purpose in [x for x in cls._setup_purpose[:-1] if x != "software"]:
                # Delete sources for this purpose
                os.remove(
                    os.path.join(
                        cls.build_dir, cls.PURPOSE_DIRS[purpose], "iob_ram_2p.v"
                    )
                )