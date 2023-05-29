from iob_module import iob_module

class iob_split2(iob_module):
    name='iob_split2'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_split2.setup()        
        iob_reg.setup()        
        iob_mux.setup()        
        iob_demux.setup()        
