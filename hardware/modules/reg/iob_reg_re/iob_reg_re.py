import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg_r import iob_reg_r
from iob_clkenrst_portmap import iob_clkenrst_portmap
from iob_clkenrst_port import iob_clkenrst_port


class iob_reg_re(iob_module):
    name = "iob_reg_re"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        super()._run_setup()

        # Verilog snippet files
        iob_clkenrst_portmap.setup()
        iob_clkenrst_port.setup()

        # Setup dependencies
        iob_reg_r.setup()

        if cls.is_top_module:
            # Setup flows of this core using LIB setup function
            setup(cls, disable_file_gen=True)

    # Copy sources of this module to the build directory
    @classmethod
    def _copy_srcs(cls):
        out_dir = cls.get_purpose_dir(cls._setup_purpose[-1])
        # Copy source to build directory
        shutil.copyfile(
            os.path.join(cls.setup_dir, "iob_reg_re.v"),
            os.path.join(cls.build_dir, out_dir, "iob_reg_re.v"),
        )

        # Ensure sources of other purposes are deleted (except software)
        # Check that latest purpose is hardware
        if cls._setup_purpose[-1] == "hardware" and len(cls._setup_purpose) > 1:
            # Purposes that have been setup previously
            for purpose in [x for x in cls._setup_purpose[:-1] if x != "software"]:
                # Delete sources for this purpose
                os.remove(
                    os.path.join(
                        cls.build_dir, cls.PURPOSE_DIRS[purpose], "iob_reg_re.v"
                    )
                )
