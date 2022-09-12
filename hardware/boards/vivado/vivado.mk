ifeq ($(IS_FPGA),1)
FPGA_OBJ=$(NAME).bit
else
FPGA_OBJ=$(NAME).edif
endif

FPGA_TEX=vivado.tex
FPGA_SERVER=$(VIVADO_SERVER)
FPGA_USER=$(VIVADO_USER)
FPGA_ENV:= bash $(VIVADOPATH)/settings64.sh

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

$(FPGA_OBJ): $(VSRC) $(VHDR) $(wildcard *.sdc)
	$(FPGA_ENV) && $(VIVADOPATH)/bin/vivado -nojournal -log vivado.log -mode batch -source fpga_tool.tcl -tclargs $(NAME) $(TOP_MODULE) "$(VSRC)" $(IS_FPGA) $(USE_DDR)
	LOG=vivado.log ../../sw/bash/vivado2tex.sh
