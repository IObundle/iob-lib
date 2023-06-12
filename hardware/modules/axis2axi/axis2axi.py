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

        if cls.is_top_module:
            # Setup flows of this core using LIB setup function
            setup(cls, disable_file_gen=True)

            # Copy testbench if this is the top module
            shutil.copyfile(
                os.path.join(cls.setup_dir, "axis2axi_tb.v"),
                os.path.join(cls.build_dir, "hardware/simulation/src", "axis2axi_tb.v"),
            )

    # Copy sources of this module to the build directory
    @classmethod
    def _copy_srcs(cls):
        out_dir = cls.get_purpose_dir(cls._setup_purpose[-1])
        # Copy sources to build directory
        shutil.copyfile(
            os.path.join(cls.setup_dir, "axis2axi.v"),
            os.path.join(cls.build_dir, out_dir, "axis2axi.v"),
        )
        shutil.copyfile(
            os.path.join(cls.setup_dir, "axis2axi_in.v"),
            os.path.join(cls.build_dir, out_dir, "axis2axi_in.v"),
        )
        shutil.copyfile(
            os.path.join(cls.setup_dir, "axis2axi_out.v"),
            os.path.join(cls.build_dir, out_dir, "axis2axi_out.v"),
        )
        shutil.copyfile(
            os.path.join(cls.setup_dir, "AxiDelay.v"),
            # Should this always be copied to simulation?
            os.path.join(cls.build_dir, out_dir, "AxiDelay.v"),
        )

        # Ensure sources of other purposes are deleted (except software)
        # Check that latest purpose is hardware
        if cls._setup_purpose[-1] == "hardware" and len(cls._setup_purpose) > 1:
            # Purposes that have been setup previously
            for purpose in [x for x in cls._setup_purpose[:-1] if x != "software"]:
                # Delete sources for this purpose
                os.remove(
                    os.path.join(cls.build_dir, cls.PURPOSE_DIRS[purpose], "axis2axi.v")
                )
                os.remove(
                    os.path.join(
                        cls.build_dir, cls.PURPOSE_DIRS[purpose], "axis2axi_in.v"
                    )
                )
                os.remove(
                    os.path.join(
                        cls.build_dir, cls.PURPOSE_DIRS[purpose], "axis2axi_out.v"
                    )
                )
                os.remove(
                    os.path.join(cls.build_dir, cls.PURPOSE_DIRS[purpose], "AxiDelay.v")
                )
