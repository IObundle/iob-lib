SHELL = /bin/bash

LIB_DOC_DIR:=$(LIB_DIR)/document
LIB_SW_DIR:=$(LIB_DIR)/software
LIB_SW_PYTHON_DIR:=$(LIB_SW_DIR)/python

presentation.pdf: presentation.tex
	pdflatex '\def\TEX{$(LIB_DOC_DIR)}\input{$<}'
	pdflatex '\def\TEX{$(LIB_DOC_DIR)}\input{$<}'

%.pdf: fpga_res asic_res figures $(DOC)top.tex
ifeq ($(DOC),pb)
	make -C ./figures pb_figs
endif
ifeq ($(DOC),ug)
	if [ ! -f ./config.tex ]; then cp $(LIB_DOC_DIR)/$(DOC)/config.tex .; fi
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
	echo "\def\TEX{$(LIB_DOC_DIR)}" > $(DOC)top.tex
	if [ -f sm_tab.tex ]; then echo "\def\SMP{Y} \def\SM{Y}" >> $@; fi
	if [ -f sp_tab.tex ]; then echo "\def\SMP{Y} \def\SP{Y}" >> $@; fi
	if [ -f td.tex ]; then echo "\def\TD{Y}" >> $@; fi
	if [ -f swreg.tex ]; then echo "\def\SWREG{Y}" >> $@; fi
	if [ -f vivado.tex -o -f quartus.tex ]; then echo "\def\FPGA{Y}" >> $(DOC)top.tex; fi
	if [ -f vivado.tex ]; then echo "\def\XILINX{Y}" >> $(DOC)top.tex; fi
	if [ -f quartus.tex ]; then echo "\def\INTEL{Y}" >> $(DOC)top.tex; fi
	if [ -f asic.tex ]; then echo "\def\ASIC{Y}" >> $(DOC)top.tex; fi
	$(if $(RESULTS), @echo "\def\RESULTS{Y}" >> $@,)
	if [ -f custom.tex ]; then echo "\def\CUSTOM{Y}" >> $@; fi
	echo "\input{$(LIB_DOC_DIR)/$(DOC)/$(DOC).tex}" >> $(DOC)top.tex

#tex files extracted from code comments
MKREGS_CONF:=$(shell if [ -f $(CORE_DIR)/mkregs.conf ]; then echo $(CORE_DIR)/mkregs.conf; fi)
texfiles: benefits.tex deliverables.tex
ifneq ($(TOP_MODULE),)
	$(LIB_SW_PYTHON_DIR)/verilog2tex.py $(CORE_DIR)/hardware/src/$(TOP_MODULE).v $(VHDR) $(VSRC) $(MKREGS_CONF)
endif


#FPGA implementation results
fpga_res:
ifeq ($(RESULTS),1)
ifneq ($(XIL_FAMILY),)
	make vivado.tex
endif
ifneq ($(INT_FAMILY),)
	make quartus.tex
endif
endif

VIVADOLOG = $(CORE_DIR)/hardware/fpga/vivado/$(XIL_FAMILY)/vivado.log
QUARTUSLOG = $(CORE_DIR)/hardware/fpga/quartus/$(INT_FAMILY)/quartus.log

#ASIC implementation results
asic_res:
ifeq ($(RESULTS),1)
ifneq ($(ASIC_NODE),)
	make asic.tex
endif
endif

ASICLOG = $(CORE_DIR)/hardware/asic/$(ASIC_NODE)/rc.log
ASICRPT = $(CORE_DIR)/hardware/asic/$(ASIC_NODE)/*.rpt

benefits.tex:
	if [ -f ../benefits.tex ]; then cp ../$@ .; else cp $(LIB_DOC_DIR)/$@ .; fi

deliverables.tex:
	if [ -f ../deliverables.tex ]; then cp ../$@ .; else cp $(LIB_DOC_DIR)/$@ .; fi

vivado.tex: $(VIVADOLOG)
	cp $(VIVADOLOG) .; LOG=$< $(LIB_SW_DIR)/vivado2tex.sh

quartus.tex: $(QUARTUSLOG)
	cp $(QUARTUSLOG) .; LOG=$< $(LIB_SW_DIR)/quartus2tex.sh

asic.tex: $(ASICLOG)
	cp $(ASICRPT) .; LOG=$< $(LIB_SW_DIR)/asic2tex.sh

$(VIVADOLOG):
	make  -C $(CORE_DIR) fpga-build FPGA_FAMILY=$(XIL_FAMILY)

$(QUARTUSLOG):
	make  -C $(CORE_DIR) fpga-build FPGA_FAMILY=$(INT_FAMILY)

$(ASICLOG):
	make  -C $(CORE_DIR) asic ASIC_NODE=$(ASIC_NODE)

#cleaning
clean:
	@find . -type f -not \( $(NOCLEAN) \) -delete
	@rm -rf figures $(DOC)top.tex
	@rm -rf $(LIB_SW_PYTHON_DIR)/__pycache__/ $(LIB_SW_PYTHON_DIR)/*.pyc

.PHONY: view texfiles figures fpga_res asic_res clean benefits.tex deliverables.tex

