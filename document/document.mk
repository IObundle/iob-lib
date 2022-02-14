#paths
LIB_DOC_DIR:=$(LIB_DIR)/document
LIB_SW_DIR:=$(LIB_DIR)/software
LIB_SW_PYTHON_DIR:=$(LIB_SW_DIR)/python

#latex build macros
BDTAB ?=1
SP ?=0
SWREGS ?=1
SWCOMPS ?=0
TD ?=0
CUSTOM ?= 0

TEX_DEFINES=\def\TEX{$(LIB_DOC_DIR)}\def\XILINX{$(XILINX)}\def\INTEL{$(INTEL)}\def\ASIC{$(ASIC)}
TEX_DEFINES +=\def\SP{$(SP)}\def\SWREGS{$(SWREGS)}\def\SWCOMPS{$(SWCOMPS)}
TEX_DEFINES +=\def\TD{$(TD)}\def\CUSTOM{$(CUSTOM)}

#add general interface signals to the list of tables
TAB +=gen_is_tab.tex

#add block diagram table to the list of tables
ifeq ($(BDTAB),1)
TAB +=bd_tab.tex
endif

#add synthesis parameters table to the list of tables
ifeq ($(SP),1)
TAB +=sp_tab.tex
endif

#add software accessible registers table to the list of tables
ifeq ($(SWREGS),1)
TAB +=$(shell grep START_TABLE $(CORE_DIR)/hardware/include/$(TOP_MODULE)_sw_reg.vh | awk '{print $$2}' | sed s/$$/_tab.tex/)
endif 


SRC:= $(wildcard ./*.tex) $(wildcard ../*.tex)

all: figures fpga_res $(TAB) $(DOC).pdf

pb.pdf: pb.aux
	evince $@ &

pb.aux: $(LIB_DOC_DIR)/pb/pb.tex $(SRC) $(TAB)
	cp -u $(LIB_DOC_DIR)/pb/pb.cls .
	pdflatex '$(TEX_DEFINES)\input{$<}'
	pdflatex '$(TEX_DEFINES)\input{$<}'

ug.pdf: ug.aux
	evince $@ &

ug.aux: $(LIB_DOC_DIR)/ug/ug.tex $(SRC) $(TAB) $(TOP_MODULE)_version.txt
	echo $(TAB)
	exit
	git rev-parse --short HEAD > shortHash.txt
ifeq ($(CUSTOM),1)
	make custom
endif
	pdflatex '$(TEX_DEFINES)\input{$<}'
ifeq ($(BIB),1)
	bibtex ug
endif
	pdflatex '$(TEX_DEFINES)\input{$<}'
	pdflatex '$(TEX_DEFINES)\input{$<}'

presentation.pdf: presentation.aux
	evince $@ &

presentation.aux: presentation.tex
	pdflatex $<
	pdflatex $<

figures:
	mkdir -p ./figures
	cp -u $(LIB_DOC_DIR)/figures/* ./figures
	cp -u ../figures/* ./figures
	make -C ./figures

#FPGA implementation results
VIVADOLOG = $(CORE_DIR)/hardware/fpga/vivado/$(XIL_FAMILY)/vivado.log
QUARTUSLOG = $(CORE_DIR)/hardware/fpga/quartus/$(INT_FAMILY)/quartus.log

fpga_res:
ifeq ($(XILINX),1)
	if [ -f $(VIVADOLOG) ]; then cp $(VIVADOLOG) .; else make fpga-build FPGA_FAMILY = $(XIL_FAMILY); fi
endif
ifeq ($(INTEL),1)
	if [ -f $(QUARTUSLOG) ]; then cp $(QUARTUSLOG) .; else make fpga-build FPGA_FAMILY = $(INT_FAMILY); fi
endif
	INTEL=$(INTEL) XILINX=$(XILINX) $(LIB_SW_DIR)/fpga2tex.sh


#block diagram
bd_tab.tex: $(CORE_DIR)/hardware/src/$(BD_VSRC)
	$(LIB_SW_PYTHON_DIR)/block2tex.py $@ $^

#synthesis parameters
sp_tab.tex: $(CORE_DIR)/hardware/src/$(TOP_MODULE).v
	$(LIB_SW_PYTHON_DIR)/param2tex.py $< $@ sm_tab.tex $(CORE_DIR)/hardware/include/$(TOP_MODULE).vh

#sw accessible registers
sw_%reg_tab.tex: $(CORE_DIR)/hardware/include/$(TOP_MODULE)_sw_reg.vh
	$(LIB_SW_PYTHON_DIR)/swreg2tex.py $< 

#general interface signals (clk and rst)
gen_is_tab.tex: $(LIB_DIR)/hardware/include/gen_if.vh
	$(LIB_SW_PYTHON_DIR)/io2tex.py $< $@

#iob native slave interface
iob_s_if_tab.tex: $(LIB_DIR)/hardware/include/iob_s_if.vh
	$(LIB_SW_PYTHON_DIR)/io2tex.py $< $@

#iob native master interface
iob_m_if_tab.tex: $(AXI_DIR)/hardware/include/iob_m_if.vh
	$(LIB_SW_PYTHON_DIR)/io2tex.py $< $@

#axi lite slave interface
axil_s_if_tab.tex: $(AXI_DIR)/hardware/include/axil_s_if.vh
	$(LIB_SW_PYTHON_DIR)/io2tex.py $< $@

#axi master interface
axi_m_if_tab.tex:  $(AXI_DIR)/hardware/include/axi_m_if.vh
	$(LIB_SW_PYTHON_DIR)/io2tex.py $< $@

#cleaning
clean: ug-clean
	@find . -type f -not \( $(NOCLEAN) \) -delete
	@rm -rf figures
	@rm -rf $(LIB_SW_PYTHON_DIR)/__pycache__/ $(LIB_SW_PYTHON_DIR)/*.pyc

.PHONY:  all figures fpga_res ug-clean clean
