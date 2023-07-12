import os

from iob_module import iob_module

from iob_reg import iob_reg


class iob2apb(iob_module):
    name = "iob2apb"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _specific_setup(cls):
        # Setup dependencies

        iob_module.generate("iob_s_port")
        iob_module.generate("iob_s_s_portmap")
        iob_module.generate("apb_m_port")
        iob_module.generate("iob_m_tb_wire")

        iob_reg.setup()
        iob_module.generate("clk_en_rst_portmap")
        iob_module.generate("clk_en_rst_port")
