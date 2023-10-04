import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()


class iob_div_pipe(iob_module):
    name = "iob_div_pipe"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.ios += [
            {
                "name": "clk",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock",
                "ports": [
                    {
                        "name": "clk",
                        "direction": "input",
                        "width": 1,
                        "descr": "Clock",
                    },
                ],
            },
            {
                "name": "div",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Division interface",
                "ports": [
                    {
                        "name": "dividend",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "divisor",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "quotient",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "remainder",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "",
                    },
                ],
            },
        ]


if __name__ == "__main__":
    iob_div_pipe.setup_as_top_module()
