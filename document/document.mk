SHELL = /bin/bash

LIB_DOC_DIR:=$(LIB_DIR)/document
LIB_SW_DIR:=$(LIB_DIR)/software
LIB_SW_PYTHON_DIR:=$(LIB_SW_DIR)/python

$(DOC).pdf: fpga_res figures $(DOC)top.tex
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

.PHONY: view texfiles figures fpga_res clean

view: $(DOC).pdf
	evince $< &

ugtop.tex: texfiles
	echo "\def\TEX{$(LIB_DOC_DIR)}" > $(DOC)top.tex
	if [ -f vivado.tex ]; then XILINX=1; else XILINX=0; fi; echo "\def\XILINX{$$XILINX}" >> $(DOC)top.tex
	if [ -f quartus.tex ]; then INTEL=1; else INTEL=0; fi; echo "\def\INTEL{$$INTEL}" >> $(DOC)top.tex
	if [ -f asic.tex ]; then ASIC=1; else ASIC=0; fi; echo "\def\ASIC{$$ASIC}" >> $(DOC)top.tex
	if [ -f sp_tab.tex ]; then SP=1; else SP=0; fi; echo "\def\SP{$$SP}" >> $@
	if [ -f sm_tab.tex ]; then SM=1; else SM=0; fi; echo "\def\SM{$$SM}" >> $@
	if [ -f swreg.tex ]; then SW=1; else SW=0; fi; echo "\def\SW{$$SW}" >> $@
	if [ -f custom.tex ]; then CUSTOM=1; else CUSTOM=0; fi; echo "\def\CUSTOM{$$CUSTOM}" >> $@
	if [ -f td.tex ]; then TD=1; else TD=0; fi; echo "\def\TD{$$TD}" >> $@
	echo "\input{$(LIB_DOC_DIR)/$(DOC)/$(DOC).tex}" >> $(DOC)top.tex

#tex files extracted from code comments
texfiles: $(MACRO_LIST)
	$(LIB_SW_PYTHON_DIR)/verilog2tex.py $(CORE_DIR)/hardware/src/$(TOP_MODULE).v $(VHDR) $(VSRC)


#needed figures
figures:
	mkdir -p ./figures
	cp -r -u $(LIB_DOC_DIR)/figures/* ../figures/* ./figures

#FPGA implementation results
fpga_res: vivado.tex quartus.tex

VIVADOLOG = $(CORE_DIR)/hardware/fpga/vivado/$(XIL_FAMILY)/vivado.log
QUARTUSLOG = $(CORE_DIR)/hardware/fpga/quartus/$(INT_FAMILY)/quartus.log

vivado.tex: $(VIVADOLOG)
	cp $(VIVADOLOG) .; LOG=$< $(LIB_SW_DIR)/vivado2tex.sh

quartus.tex: $(QUARTUSLOG)
	cp $(QUARTUSLOG) .; LOG=$< $(LIB_SW_DIR)/quartus2tex.sh

$(VIVADOLOG):
	make  -C $(CORE_DIR) fpga-build FPGA_FAMILY=$(XIL_FAMILY)

$(QUARTUSLOG):
	make  -C $(CORE_DIR) fpga-build FPGA_FAMILY=$(INT_FAMILY)

#cleaning
clean:
	@find . -type f -not \( $(NOCLEAN) \) -delete
	@rm -rf figures $(DOC)top.tex
	@rm -rf $(LIB_SW_PYTHON_DIR)/__pycache__/ $(LIB_SW_PYTHON_DIR)/*.pyc
