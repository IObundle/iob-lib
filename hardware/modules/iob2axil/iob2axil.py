from iob_module import iob_module

class iob2axil(iob_module):
    def __init__(self, **kwargs):
        super().__init__(
                name='iob2axil',
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
            "axil_m_port",
            "axil_m_portmap",
            "iob_m_tb_wire",
            "axil_wire",
        ]
        self.modules = ["iob2axil.v"]
