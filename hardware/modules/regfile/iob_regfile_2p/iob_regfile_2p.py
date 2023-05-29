from iob_module import iob_module

class iob_regfile_2p(iob_module):
    name='iob_regfile_2p'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_regfile_2p.setup()        
