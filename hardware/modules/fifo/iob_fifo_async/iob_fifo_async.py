import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_utils import iob_utils
from iob_gray_counter import iob_gray_counter
from iob_gray2bin import iob_gray2bin
from iob_sync import iob_sync
from iob_asym_converter import iob_asym_converter
from iob_ram_t2p import iob_ram_t2p


class iob_fifo_async(iob_module):
    name = "iob_fifo_async"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Setup dependencies

        iob_utils.setup()
        iob_gray_counter.setup()
        iob_gray2bin.setup()
        iob_sync.setup()
        iob_asym_converter.setup()

        iob_ram_t2p.setup(purpose="simulation")

        if cls.is_top_module:
            # Setup flows of this core using LIB setup function
            setup(cls, disable_file_gen=True)

            # Copy testbench if this is the top module
            shutil.copyfile(
                os.path.join(cls.setup_dir, "iob_fifo_async_tb.v"),
                os.path.join(
                    cls.build_dir, "hardware/simulation/src", "iob_fifo_async_tb.v"
                ),
            )

    # Copy sources of this module to the build directory
    @classmethod
    def _copy_srcs(cls):
        out_dir = cls.get_purpose_dir(cls._setup_purpose[-1])
        # Copy source to build directory
        shutil.copyfile(
            os.path.join(cls.setup_dir, "iob_fifo_async.v"),
            os.path.join(cls.build_dir, out_dir, "iob_fifo_async.v"),
        )

        # Ensure sources of other purposes are deleted (except software)
        # Check that latest purpose is hardware
        if cls._setup_purpose[-1] == "hardware" and len(cls._setup_purpose) > 1:
            # Purposes that have been setup previously
            for purpose in [x for x in cls._setup_purpose[:-1] if x != "software"]:
                # Delete sources for this purpose
                os.remove(
                    os.path.join(
                        cls.build_dir, cls.PURPOSE_DIRS[purpose], "iob_fifo_async.v"
                    )
                )
