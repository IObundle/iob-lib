# (c) 2022-Present IObundle, Lda, all rights reserved
#
# Makefile for creating documents in the build directory
#

SHELL = /bin/bash

# include core basic info
include ../info.mk

#include local doc segment
ifneq ($(wildcard document.mk),)
include document.mk
endif

#default DOC
DOC?=pb

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
pb.pdf: results pb_figs pbtop.tex
	pdflatex -jobname pb pbtop.tex
	pdflatex -jobname pb pbtop.tex

#pb top file containing the definition of sections to include
pbtop.tex:
	make doctop DOC=pb

#build user guide document type
ug.pdf: results ug_figs ugtop.tex
	pdflatex -jobname ug ugtop.tex
	if [ -f *.bib ]; then bibtex ug; fi
	pdflatex -jobname ug ugtop.tex
	pdflatex -jobname ug ugtop.tex


#ug top file containing the definition of sections to include
ugtop.tex:
	if [ -f sm_tab.tex ]; then echo "\def\SMP{Y} \def\SM{Y}" >> $@; fi
	if [ -f sp_tab.tex ]; then echo "\def\SMP{Y} \def\SP{Y}" >> $@; fi
	if [ -f td.tex ]; then echo "\def\TD{Y}" >> $@; fi
	if [ -f swreg.tex ]; then echo "\def\SWREG{Y}" >> $@; fi
	if [ $(ASICSYNTH) == 1 ]; then echo "\def\ASICSYNTH{Y}" >> $@; fi
	make doctop DOC=ug

doctop:
	echo "\def\NAME{$(NAME)}" >> $(DOC)top.tex
	if [ $(RESULTS) ]; then echo "\def\RESULTS{Y}" >> $(DOC)top.tex; fi
	if [ $(INTEL_FPGA)$(AMD_FPGA) ]; then echo "\def\FPGA{Y}" >> $(DOC)top.tex; fi
	if [ $(AMD_FPGA) ]; then echo "\def\AMD{Y}" >> $(DOC)top.tex; fi
	if [ $(INTEL_FPGA) ]; then echo "\def\INTEL{Y}" >> $(DOC)top.tex; fi
	if [ $(ASIC_NODE) ]; then echo "\def\ASIC{Y}" >> $(DOC)top.tex; fi
	if [ -f custom.tex ]; then echo "\def\CUSTOM{Y}" >> $(DOC)top.tex; fi
	echo "\input{$(DOC).tex}" >> $(DOC)top.tex

#view document
view: $(DOC).pdf
	evince $< &

clean:
	@find . -maxdepth 1 -type f -not \( -name Makefile -o -name \*.mk -o -name "*.expected" \) -delete
	make -C figures clean 
	@rm -rf $(PYTHON_DIR)/__pycache__

test: clean $(TEST_LIST)

debug:
	@echo VHDR=$(VHDR)
	@echo VSRC=$(VSRC)
	@echo RESULTS=$(RESULTS)
	@echo FPGA=$(FPGA)
	@echo INTEL_FPGA=$(INTEL_FPGA)
	@echo AMD_FPGA=$(AMD_FPGA)
	@echo ASIC_NODE=$(ASIC_NODE)

.PHONY: view doctop figures results clean test debug

