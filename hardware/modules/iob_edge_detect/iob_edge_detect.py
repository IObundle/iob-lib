from iob_module import iob_module

class iob_edge_detect(iob_module):
    name='iob_edge_detect'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_edge_detect.setup()        
        iob_reg.setup()        
