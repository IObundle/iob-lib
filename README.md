# iob-lib
This repository contains a set of Python scripts, Verilog, and C sources to
simplify the development of subsystem IP cores.

It is used as a submodule in the [IOb-SoC](https://github.com/IObundle/iob-soc)
RISC-V-based SoC, and associated projects.

## Code Style
#### Python Code
[![Recommended python code style:
black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
- Python format workflow:
    - install [black](https://black.readthedocs.io/en/stable/)
    - run black manually:
        - `make format` or `./scripts/black_format.py`
    - (optional): [integrate with your preferred
      IDE](https://black.readthedocs.io/en/stable/integrations/editors.html)
    - black formatting for other repositories:
        - call `black_format.py` script in LIB submodule from the repository
          top level:
        ```make
        # repository top level Makefile
        format:
           @./$(LIB_DIR)/scripts/black_format.py
        ```
#### C/C++ Code
- Recommended C/C++ code style: [LLVM](https://llvm.org/docs/CodingStandards.html)
- C/C++ format workflow:
    - install [clang-format](https://black.readthedocs.io/en/stable/)
    - run clang-format manually:
        - `make format` or `./scripts/clang_format.py`
    - (optional) [integrate with your preferred
      IDE](https://clang.llvm.org/docs/ClangFormat.html#vim-integration)
    - C/C++ formatting for other repositories:
        - copy `.clang-format` to new repository top level
        - call `clang_format.py` script in LIB submodule from the repository
          top level:
        ```make
        # repository top level Makefile
        format:
           @./$(LIB_DIR)/scripts/clang_format.py
        ```
#### Github Actions
- To check for format compliance in other repositories:
    - copy `./github/workflows/format.yml` to new repository
    - update path to format scripts accordingly

## Tests
Currently tests are automated for the memory modules in the `test.mk` makefile.
Run tests for all memory modules with the command: 
```
make -f test.mk test
```
