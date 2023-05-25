from iob_module import iob_module

class iob_f2s_1bit_sync(iob_module):
    def __init__(self, **kwargs):
        super().__init__(
                name='iob_f2s_1bit_sync',
                version='V0.10',
                **kwargs
                )

    # This module accepts the following non-standard parameters:
    # out_dir: Output directory for placement of source files during setup
    def setup(self, out_dir="hardware/src", **kwargs):
        super().setup(**kwargs)

        self.headers = []
        self.modules = ["iob_f2s_1bit_sync.v", "iob_reg.v"]
