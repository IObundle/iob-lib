from iob_module import iob_module

class apb2iob(iob_module):
    name='apb2iob'
    version='V0.10'

    @classmethod
    def _run_setup(cls):
        iob_wire.setup()
        apb_s_port.setup()
        iob_s_portmap.setup()
        apb2iob.setup()
        iob_reg.setup()

