from iob_module import iob_module

class iob_fifo_sync(iob_module):
    def __init__(self, **kwargs):
        super().__init__(
                name='iob_fifo_sync',
                version='V0.10',
                **kwargs
                )

    # This module accepts the following non-standard parameters:
    # out_dir: Output directory for placement of source files during setup
    def setup(self, out_dir="hardware/src", **kwargs):
        super().setup(**kwargs)

        self.headers = []
        self.modules = [
            "iob_fifo_sync.v",
            "iob_reg_r",
            "iob_reg.v",
            "iob_counter",
            "iob_asym_converter",
        ]
        self.sim_headers = []
        self.sim_modules = ["iob_ram_2p"]
