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

$(NAME)_version.txt:
	echo $(VERSION) > version.txt


SW_DIR:=../sw
PYTHON_DIR:=$(SW_DIR)/python

build: $(DOC).pdf

presentation.pdf: presentation.tex
	pdflatex $<
	pdflatex $<


%.pdf: fpga_res asic_res figures $(DOC)top.tex
ifeq ($(DOC),pb)
	make -C ./figures pb_figs
endif
ifeq ($(DOC),ug)
	make -C ./figures ug_figs
	echo $(VERSION) > version.tex
	git rev-parse --short HEAD > shortHash.tex
endif
	pdflatex -jobname $(DOC) $(DOC)top.tex
	if [ -f *.bib ]; then bibtex ug; fi
	pdflatex -jobname $(DOC) $(DOC)top.tex
	pdflatex -jobname $(DOC) $(DOC)top.tex

view: $(DOC).pdf
	evince $< &

$(DOC)top.tex: texfiles
	cp tsrc/* .
	if [ -f sm_tab.tex ]; then echo "\def\SMP{Y} \def\SM{Y}" >> $@; fi
	if [ -f sp_tab.tex ]; then echo "\def\SMP{Y} \def\SP{Y}" >> $@; fi
	if [ -f td.tex ]; then echo "\def\TD{Y}" >> $@; fi
	if [ -f swreg.tex ]; then echo "\def\SWREG{Y}" >> $@; fi
	if [ -f vivado.tex -o -f quartus.tex ]; then echo "\def\FPGA{Y}" >> $@; fi
	if [ -f vivado.tex ]; then echo "\def\XILINX{Y}" >> $@; fi
	if [ -f quartus.tex ]; then echo "\def\INTEL{Y}" >> $@; fi
	if [ -f asic.tex ]; then echo "\def\ASIC{Y}" >> $@; fi
	$(if $(RESULTS), @echo "\def\RESULTS{Y}" >> $@,)
	if [ -f custom.tex ]; then echo "\def\CUSTOM{Y}" >> $@; fi
	echo "\input{$(DOC).tex}" >> $@

#tex files extracted from code comments
ifneq ($(wildcard tsrc/mkregs.conf),)
MKREGS_CONF:=tsrc/mkregs.conf
endif
VHDR:=$(wildcard ../hw/vsrc/*.vh)
VSRC:=$(wildcard ../hw/vsrc/*.v)

texfiles:
	$(PYTHON_DIR)/verilog2tex.py ../hw/vsrc/$(TOP_MODULE).v $(VHDR) $(VSRC) $(MKREGS_CONF)


#include implementation results
fpga_res:
ifeq ($(RESULTS),1)
ifneq ($(XIL_FAMILY),)
	make vivado.tex
endif
ifneq ($(INT_FAMILY),)
	make quartus.tex
endif
endif

VIVADOLOG = ../hw/fpga/vivado.log
QUARTUSLOG = ../hw/fpga/quartus.log

#ASIC implementation results
asic_res:
ifeq ($(RESULTS),1)
ifneq ($(ASIC_NODE),)
	make asic.tex
endif
endif

ASICLOG = ../hw/asic/$(ASIC_NODE)/rc.log
ASICRPT = ../hw/asic/$(ASIC_NODE)/*.rpt

vivado.tex: $(VIVADOLOG)
	cp $(VIVADOLOG) .; LOG=$< ../sw/vivado2tex.sh

quartus.tex: $(QUARTUSLOG)
	cp $(QUARTUSLOG) .; LOG=$< ../sw/quartus2tex.sh

asic.tex: $(ASICLOG)
	cp $(ASICRPT) .; LOG=$< ../sw/asic2tex.sh

$(VIVADOLOG):
	make  -C ../hw/fpga build FPGA_FAMILY=$(XIL_FAMILY) TOP_MODULE=$(TOP_MODULE)

$(QUARTUSLOG):
	make  -C ../hw/fpga build FPGA_FAMILY=$(INT_FAMILY) TOP_MODULE=$(TOP_MODULE)

$(ASICLOG):
	make  -C ../hw/syn build ASIC_NODE=$(ASIC_NODE)

#cleaning
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
	@echo $(wildcard document.mk)

.PHONY: view texfiles figures fpga_res asic_res clean

