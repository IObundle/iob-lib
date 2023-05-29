from iob_module import iob_module

class iob_pulse_gen(iob_module):
    name='iob_pulse_gen'
    version='V0.10'

    @classmethod
    def _run_setup(cls):

        iob_pulse_gen.setup()        
        iob_reg.setup()        
        iob_counter.setup()        
