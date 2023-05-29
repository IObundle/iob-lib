from iob_module import iob_module

class iob_ram_dp_be_xil(iob_module):
    name='iob_ram_dp_be_xil'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_ram_dp_be_xil.setup()        
