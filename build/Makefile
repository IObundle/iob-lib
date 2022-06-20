SHELL:=/bin/bash
export

include info.mk
include version.mk

#
# SIMULATE
#

sim-build: build-dir
	make -C sim build

sim-run: sim-build
	make -C sim run

sim-test: build-dir
	make -C sim test

sim-clean: build-dir
	make -C sim clean

sim-debug: build-dir
	make -C sim debug

#
# FPGA
#

fpga-build: build-dir
	make -C fpga build

fpga-run: build-dir
	make -C fpga run

fpga-test: build-dir
	make -C fpga test

fpga-clean: build-dir
	make -C fpga clean

fpga-debug: build-dir
	make -C fpga debug

#
# DOCUMENT
#

doc-build: build-dir
	make -C doc $(DOC).pdf

doc-test: build-dir
	make -C doc test

doc-clean: build-dir
	make -C doc clean

doc-debug: build-dir
	make -C doc debug

#
# TEST
#

test: build-clean sim-test fpga-test #doc-test


#
# CLEAN
#

clean: sim-clean fpga-clean #doc-clean


.PHONY: build-dir build-clean build-debug \
	sim-build sim-run sim-test sim-debug sim-clean \
	fpga-build fpga-test fpga-clean fpga-debug \
	doc-build doc-test doc-clean doc-debug \
	test clean
