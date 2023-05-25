from iob_module import iob_module

class iob2apb(iob_module):
    def __init__(self, **kwargs):
        super().__init__(
                name='iob2apb',
                version='V0.10',
                **kwargs
                )

    # This module accepts the following non-standard parameters:
    # out_dir: Output directory for placement of source files during setup
    def setup(self, out_dir="hardware/src", **kwargs):
        super().setup(**kwargs)

        self.headers = [
                "iob_s_port",
                "iob_s_s_portmap",
                "apb_m_port",
                "iob_m_tb_wire",
            ]
        self.modules = ["iob2apb.v", "iob_reg.v"]
