from iob_module import iob_module

class iob_iob2wishbone(iob_module):
    def __init__(self, **kwargs):
        super().__init__(
                name='iob_iob2wishbone',
                version='V0.10',
                **kwargs
                )

    # This module accepts the following non-standard parameters:
    # out_dir: Output directory for placement of source files during setup
    def setup(self, out_dir="hardware/src", **kwargs):
        super().setup(**kwargs)

        self.headers = []
        self.modules = ["iob_iob2wishbone.v", "iob_reg_re"]
