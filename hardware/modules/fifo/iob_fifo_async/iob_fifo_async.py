from iob_module import iob_module

class iob_fifo_async(iob_module):
    def __init__(self, **kwargs):
        super().__init__(
                name='iob_fifo_async',
                version='V0.10',
                **kwargs
                )

    # This module accepts the following non-standard parameters:
    # out_dir: Output directory for placement of source files during setup
    def setup(self, out_dir="hardware/src", **kwargs):
        super().setup(**kwargs)

        self.headers = []
        self.modules = [
            "iob_fifo_async.v",
            "iob_gray_counter",
            "iob_gray2bin",
            "iob_sync",
            "iob_asym_converter",
        ]
        self.sim_headers = []
        self.sim_modules = ["iob_ram_t2p"]
