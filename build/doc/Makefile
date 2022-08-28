#
# This file becomes the document Makefile when copied to the build
# directory
#

SHELL = /bin/bash

#include local doc segment
ifneq ($(wildcard document.mk),)
include document.mk
endif

#default DOC
DOC?=pb

#path to verilog2python script
PYTHON_DIR:=../sw/python

#create version tex segment
include ../version.mk
version.tex:
	echo $(VERSION_STR) > version.tex

#make product brief figures
pb_figs:
	make -C ./figures pb_figs

#make user guide figures
ug_figs:
	make -C ./figures ug_figs

#build document
build: $(DOC).pdf

#build presentation document type
presentation.pdf: presentation.tex
	pdflatex $<
	pdflatex $<

#build product brief document type
pb.pdf: results pb_figs $(DOC)top.tex
	pdflatex -jobname $(DOC) $(DOC)top.tex
	pdflatex -jobname $(DOC) $(DOC)top.tex

#build user guide document type
ug.pdf: version.tex results ug_figs $(DOC)top.tex
	git rev-parse --short HEAD > shortHash.tex
	pdflatex -jobname $(DOC) $(DOC)top.tex
	if [ -f *.bib ]; then bibtex ug; fi
	pdflatex -jobname $(DOC) $(DOC)top.tex
	pdflatex -jobname $(DOC) $(DOC)top.tex

#view document
view: $(DOC).pdf
	evince $< &

#create document top file containing the definition of sections to include
$(DOC)top.tex: texfiles
	cp tsrc/* .
	if [ -f sm_tab.tex ]; then echo "\def\SMP{Y} \def\SM{Y}" >> $@; fi
	if [ -f sp_tab.tex ]; then echo "\def\SMP{Y} \def\SP{Y}" >> $@; fi
	if [ -f td.tex ]; then echo "\def\TD{Y}" >> $@; fi
	if [ -f swreg.tex ]; then echo "\def\SWREG{Y}" >> $@; fi
	if [ $(RESULTS) == 1 ]; then echo "\def\RESULTS{Y}" >> $@; fi
	if [ -f ../hw/fpga/vivado.tex ]; then cp ../hw/fpga/vivado.tex .; fi
	if [ -f ../hw/fpga/quartus.tex ]; then cp ../hw/fpga/quartus.tex .; fi
	if [ -f vivado.tex -o -f quartus.tex ]; then echo "\def\FPGA{Y}" >> $@; fi
	if [ -f vivado.tex ]; then echo "\def\XILINX{Y}" >> $@; fi
	if [ -f quartus.tex ]; then echo "\def\INTEL{Y}" >> $@; fi
	if [ -f genus.tex ]; then echo "\def\ASIC{Y}" >> $@; fi
	if [ $(ASICSYNTH) == 1 ]; then echo "\def\ASICSYNTH{Y}" >> $@; fi
	if [ -f custom.tex ]; then echo "\def\CUSTOM{Y}" >> $@; fi
	echo "\input{$(DOC).tex}" >> $@

#generate tex files from code comments
ifneq ($(wildcard tsrc/mkregs.conf),)
MKREGS_CONF:=tsrc/mkregs.conf
endif
VHDR:=$(wildcard ../hw/vsrc/*_conf.vh) $(wildcard ../hw/vsrc/*.vh)
VSRC:=$(wildcard ../hw/vsrc/*.v)
texfiles:
	$(PYTHON_DIR)/verilog2tex.py ../hw/vsrc/$(TOP_MODULE).v $(VHDR) $(VSRC) $(MKREGS_CONF)

#run EDA tools to get results to include in document 
results:
ifeq ($(RESULTS), 1)
ifneq ($(INT_FAMILY),)
	make  -C ../hw/fpga build FPGA_FAMILY=$(INT_FAMILY) TOP_MODULE=$(TOP_MODULE)
endif
ifneq ($(XIL_FAMILY),)
	make  -C ../hw/fpga build FPGA_FAMILY=$(XIL_FAMILY) TOP_MODULE=$(TOP_MODULE)
endif
ifneq ($(ASIC_NODE),)
	make  -C ../hw/syn build ASIC_NODE=$(ASIC_NODE)
endif
endif

#clean
clean:
	@find . -maxdepth 1 -type f -not \( -name Makefile -o -name \*.mk \) -delete
	make -C figures clean 
	@rm -rf $(PYTHON_DIR)/__pycache__

debug:
	@echo $(VHDR)
	@echo $(VSRC)
	@echo $(RESULTS)
	@echo $(INT_FAMILY)
	@echo $(XIL_FAMILY)
	@echo $(ASIC_NODE)
	@echo $(wildcard document.mk)

.PHONY: view texfiles figures results clean

