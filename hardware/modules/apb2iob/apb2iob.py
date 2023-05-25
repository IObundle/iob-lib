from iob_module import iob_module

class apb2iob(iob_module):
    def __init__(self, **kwargs):
        super().__init__(
                name='apb2iob',
                version='V0.10',
                **kwargs
                )

    # This module accepts the following non-standard parameters:
    # out_dir: Output directory for placement of source files during setup
    def setup(self, out_dir="hardware/src", **kwargs):
        super().setup(**kwargs)

        self.headers = ["iob_wire", "apb_s_port", "iob_s_portmap"]
        self.modules = ["apb2iob.v", "iob_reg.v"]

