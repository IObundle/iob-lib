from iob_module import iob_module

class iob2axi(iob_module):
    def __init__(self, **kwargs):
        super().__init__(
                name='iob2axi',
                version='V0.10',
                **kwargs
                )

    # This module accepts the following non-standard parameters:
    # out_dir: Output directory for placement of source files during setup
    def setup(self, out_dir="hardware/src", **kwargs):
        super().setup(**kwargs)

        self.headers = [
                "m_axi_m_port",
                "m_axi_write_m_port",
                "m_axi_read_m_port",
                "m_m_axi_write_portmap",
                "m_m_axi_read_portmap",
            ]
        self.modules = ["iob2axi.v", "iob2axi_wr.v", "iob2axi_rd.v", "iob_fifo_sync"]
