# iob-lib

This repository contains a set of Verilog macros to simplify the development of IP cores.

It is used as a submodule in the IOb-SoC (https://github.com/IObundle/iob-soc) RISC-V-based SoC, and associated projects.

## Tests
Currently tests are automated for the memory modules in the `test.mk` makefile.
Run tests for all memory modules with the command: 
```
make -f test.mk test
```
