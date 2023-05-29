from iob_module import iob_module

class iob_merge(iob_module):
    name='iob_merge'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_merge.setup()        
        iob_reg_e.setup()        
        iob_mux.setup()        
        iob_demux.setup()        
