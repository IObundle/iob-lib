import os
import shutil

from iob_module import iob_module
from iob_s_port import iob_s_port
from iob_s_s_portmap import iob_s_s_portmap
from apb_m_port import apb_m_port
from iob_m_tb_wire import iob_m_tb_wire
from iob_reg import iob_reg

class iob2apb(iob_module):
    name='iob2apb'
    version='V0.10'
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        out_dir = super()._run_setup()
        # Copy source to build directory
        shutil.copyfile(os.path.join(cls.setup_dir, 'iob2apb.v'), os.path.join(cls.build_dir, out_dir, 'iob2apb.v'))
        # Setup dependencies

        iob_s_port.setup()                
        iob_s_s_portmap.setup()        
        apb_m_port.setup()        
        iob_m_tb_wire.setup()        

        iob_reg.setup()        
