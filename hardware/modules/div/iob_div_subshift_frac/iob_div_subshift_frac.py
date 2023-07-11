import os
import shutil

from iob_module import iob_module
from setup import setup

from iob_reg import iob_reg
from iob_reg_e import iob_reg_e
from iob_div_subshift import iob_div_subshift


class iob_div_subshift_frac(iob_module):
    name = "iob_div_subshift_frac"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _post_setup(cls):

        # Verilog snippet files
        iob_module.generate("clk_en_rst_portmap")
        iob_module.generate("clk_en_rst_port")

        # Setup dependencies
        iob_reg.setup()
        iob_reg_e.setup()
        iob_div_subshift.setup()

        super()._post_setup()

        # Setup flows of this core using LIB setup function
        setup(cls, disable_file_gen=True)
