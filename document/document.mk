LIB_DOC_DIR:=$(LIB_DIR)/document
LIB_SW_DIR:=$(LIB_DIR)/software
LIB_SW_PYTHON_DIR:=$(LIB_SW_DIR)/python

VHDR +=$(LIB_DIR)/hardware/include/gen_if.vh

.PHONY: texfiles all figures fpga_res clean

SHELL = /bin/bash
top.tex: texfiles
	echo "\def\TEX{$(LIB_DOC_DIR)}" > top.tex
	if [ -f sp_tab.tex ]; then SP=1; else SP=0; fi; echo "\def\SP{$$SP}" >> top.tex
	if [ -f sm_tab.tex ]; then SM=1; else SM=0; fi; echo "\def\SM{$$SM}" >> top.tex
	if [ `find . -name \*reg_tab.tex -print -quit` ]; then SWREGS=1; else SWREGS=0; fi; echo "\def\SWREGS{$$SWREGS}" >> top.tex
	if [ -f sw_tab.tex ]; then SWCOMPS=1; else SWCOMPS=0; fi; echo "\def\SWCOMPS{$$SWCOMPS}" >> top.tex
	if [ `find figures -name *td_fig.pdf -print -quit` ]; then TD=1; else TD=0; fi; echo "\def\TD{$$TD}" >> top.tex
	if [ -f custom.tex ]; then CUSTOM=1; else CUSTOM=0; fi; echo "\def\CUSTOM{$$CUSTOM}" >> top.tex
	if [ -f vivado.tex ]; then XILINX=1; else XILINX=0; fi; echo "\def\XILINX{$$XILINX}" >> top.tex
	if [ -f quartus.tex ]; then INTEL=1; else INTEL=0; fi; echo "\def\INTEL{$$INTEL}" >> top.tex
	if [ -f asic.tex ]; then ASIC=1; else ASIC=0; fi; echo "\def\ASIC{$$ASIC}" >> top.tex
	echo "\input{$(LIB_DOC_DIR)/ug/$(DOC).tex}" >> top.tex

texfiles: $(MACRO_LIST)
	$(LIB_SW_PYTHON_DIR)/verilog2tex.py $(CORE_DIR)/hardware/src/$(TOP_MODULE).v $(VHDR) $(VSRC)
	echo $(VHDR)


all: fpga_res $(DOC).pdf

pb.pdf: pb.aux
	evince $@ &

pb.aux: top.tex
	mkdir -p figures
	cp -u $(LIB_DOC_DIR)/figures/* ../figures/bd.odg  ./figures
	make -C ./figures
	cp -u $(LIB_DOC_DIR)/pb/pb.cls .
	pdflatex $<
	pdflatex $<

ug.pdf: $(TOP_MODULE)_version.txt ug.aux
	evince $@ &

ug.aux: top.tex
	mkdir -p figures
	cp -u $(LIB_DOC_DIR)/figures/* ../figures/* ./figures
	make -C ./figures
	git rev-parse --short HEAD > shortHash.txt
	pdflatex $<
	if [ -f *.bib ]; then bibtex ug; fi
	pdflatex $<
	pdflatex $<

presentation.pdf: presentation.aux
	evince $@ &

presentation.aux: presentation.tex
	pdflatex $<
	pdflatex $<

figures:
	mkdir -p ./figures
	cp -u $(LIB_DOC_DIR)/figures/* ./figures

#FPGA implementation results
VIVADOLOG = $(CORE_DIR)/hardware/fpga/vivado/$(XIL_FAMILY)/vivado.log
QUARTUSLOG = $(CORE_DIR)/hardware/fpga/quartus/$(INT_FAMILY)/quartus.log

vivado.tex: $(VIVADOLOG)
	cp $(VIVADOLOG) .; LOG=$< $(LIB_SW_DIR)/vivado2tex.sh

quartus.tex: $(QUARTUSLOG)
	cp $(QUARTUSLOG); LOG=$< $(LIB_SW_DIR)/quartus2tex.sh

$(VIVADOLOG):
	make  -C $(CORE_DIR) fpga-build FPGA_FAMILY=$(XIL_FAMILY)

$(QUARTUSLOG):
	make  -C $(CORE_DIR) fpga-build FPGA_FAMILY=$(INT_FAMILY)

fpga_res: vivado.tex quartus.tex

#cleaning
clean:
	@find . -type f -not \( $(NOCLEAN) \) -delete
	@rm -rf figures top.tex
	@rm -rf $(LIB_SW_PYTHON_DIR)/__pycache__/ $(LIB_SW_PYTHON_DIR)/*.pyc
