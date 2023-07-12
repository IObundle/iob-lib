import os

from iob_module import iob_module

from iob_reg import iob_reg


class apb2iob(iob_module):
    name = "apb2iob"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies
        iob_module.generate("iob_wire")
        iob_module.generate("apb_s_port")
        iob_module.generate("iob_s_portmap")
        iob_module.generate("clk_en_rst_port")
        iob_module.generate("clk_en_rst_portmap")
        iob_reg.setup()
