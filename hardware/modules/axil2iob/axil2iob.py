from iob_module import iob_module

class axil2iob(iob_module):
    def __init__(self, **kwargs):
        super().__init__(
                name='axil2iob',
                version='V0.10',
                **kwargs
                )

    # This module accepts the following non-standard parameters:
    # out_dir: Output directory for placement of source files during setup
    def setup(self, out_dir="hardware/src", **kwargs):
        super().setup(**kwargs)

        self.headers = [
            "axil_s_port",
            "axil_s_s_portmap",
            "iob_m_port",
            "iob_m_portmap",
            "iob_wire",
            "iob_s_portmap",
        ]
        self.modules = ["axil2iob.v"]
