from iob_module import iob_module

class axis2axi(iob_module):
    def __init__(self, **kwargs):
        super().__init__(
                name='axis2axi',
                version='V0.10',
                **kwargs
                )

    # This module accepts the following non-standard parameters:
    # out_dir: Output directory for placement of source files during setup
    def setup(self, out_dir="hardware/src", **kwargs):
        super().setup(**kwargs)

        self.headers = [
                "axi_m_port",
                "axi_m_write_port",
                "axi_m_read_port",
                "axi_m_m_write_portmap",
                "axi_m_m_read_portmap",
            ]
        self.modules = [
                "axis2axi.v",
                "axis2axi_in.v",
                "axis2axi_out.v",
                "iob_fifo_sync",
                "iob_counter",
                "iob_reg_r",
                "iob_reg_re",
                "iob_asym_converter",
            ]
        self.sim_modules = ["AxiDelay.v", "axi_ram", "iob_ram_t2p"]
        self.sim_headers = []
