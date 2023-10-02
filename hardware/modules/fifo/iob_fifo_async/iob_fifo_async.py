import os

# Find python modules
if __name__ == "__main__":
    import sys
    sys.path.append("./scripts")
from iob_module import iob_module
if __name__ == "__main__":
    iob_module.find_modules()

from iob_utils import iob_utils
from iob_gray_counter import iob_gray_counter
from iob_gray2bin import iob_gray2bin
from iob_sync import iob_sync
from iob_asym_converter import iob_asym_converter
from iob_ram_t2p import iob_ram_t2p


class iob_fifo_async(iob_module):
    name = "iob_fifo_async"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.submodules = [
            iob_utils,
            iob_gray_counter,
            iob_gray2bin,
            iob_sync,
            iob_asym_converter,
            (iob_ram_t2p, {"purpose": "simulation"}),
        ]

        cls.ios += [
            {
                "name": "write",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "description": "Write interface",
                "ports": [
                    {
                        "name": "w_clk",
                        "direction": "input",
                        "width": 1,
                        "description": "Write clock",
                    },
                    {
                        "name": "w_cke",
                        "direction": "input",
                        "width": 1,
                        "description": "Write clock enable",
                    },
                    {
                        "name": "w_arst",
                        "direction": "input",
                        "width": 1,
                        "description": "Write async reset",
                    },
                    {
                        "name": "w_rst",
                        "direction": "input",
                        "width": 1,
                        "description": "Write sync reset",
                    },
                    {
                        "name": "w_en",
                        "direction": "input",
                        "width": 1,
                        "description": "Write enable",
                    },
                    {
                        "name": "w_data",
                        "direction": "input",
                        "width": "W_DATA_W",
                        "description": "Write data",
                    },
                    {
                        "name": "w_full",
                        "direction": "output",
                        "width": 1,
                        "description": "Write full signal",
                    },
                    {
                        "name": "w_empty",
                        "direction": "output",
                        "width": 1,
                        "description": "Write empty signal",
                    },
                    {
                        "name": "w_level",
                        "direction": "output",
                        "width": "ADDR_W",
                        "description": "Write fifo level",
                    },
                ],
            },
            {
                "name": "read",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "description": "Read interface",
                "ports": [
                    {
                        "name": "r_clk",
                        "direction": "input",
                        "width": 1,
                        "description": "Read clock",
                    },
                    {
                        "name": "r_cke",
                        "direction": "input",
                        "width": 1,
                        "description": "Read clock enable",
                    },
                    {
                        "name": "r_arst",
                        "direction": "input",
                        "width": 1,
                        "description": "Read async reset",
                    },
                    {
                        "name": "r_rst",
                        "direction": "input",
                        "width": 1,
                        "description": "Read sync reset",
                    },
                    {
                        "name": "r_en",
                        "direction": "input",
                        "width": 1,
                        "description": "Read enable",
                    },
                    {
                        "name": "r_data",
                        "direction": "output",
                        "width": "R_DATA_W",
                        "description": "Read data",
                    },
                    {
                        "name": "r_full",
                        "direction": "output",
                        "width": 1,
                        "description": "Read full signal",
                    },
                    {
                        "name": "r_empty",
                        "direction": "output",
                        "width": 1,
                        "description": "Read empty signal",
                    },
                    {
                        "name": "r_level",
                        "direction": "output",
                        "width": "ADDR_W",
                        "description": "Read fifo level",
                    },
                ],
            },
            {
                "name": "extmem",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "description": "External memory interface",
                "ports": [
                    {
                        "name": "ext_mem_clk",
                        "direction": "output",
                        "width": 1,
                        "description": "Memory clock",
                    },
                    #  Write port
                    {
                        "name": "ext_mem_w_en",
                        "direction": "output",
                        "width": "R",
                        "description": "Memory write enable",
                    },
                    {
                        "name": "ext_mem_w_addr",
                        "direction": "output",
                        "width": "MINADDR_W",
                        "description": "Memory write address",
                    },
                    {
                        "name": "ext_mem_w_data",
                        "direction": "output",
                        "width": "MAXDATA_W",
                        "description": "Memory write data",
                    },
                    #  Read port
                    {
                        "name": "ext_mem_r_en",
                        "direction": "output",
                        "width": "R",
                        "description": "Memory read enable",
                    },
                    {
                        "name": "ext_mem_r_addr",
                        "direction": "output",
                        "width": "MINADDR_W",
                        "description": "Memory read address",
                    },
                    {
                        "name": "ext_mem_r_data",
                        "direction": "input",
                        "width": "MAXDATA_W",
                        "description": "Memory read data",
                    },
                ],
            },
        ]

if __name__ == "__main__":
    iob_fifo_async.setup_as_top_module()
