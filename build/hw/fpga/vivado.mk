FPGA_OBJ=$(TOP_MODULE).edif
FPGA_TEX=vivado.tex
FPGA_SERVER=$(VIVADO_SERVER)
FPGA_USER=$(VIVADO_USER)
FPGA_ENV:= bash $(VIVADOPATH)/settings64.sh

$(FPGA_OBJ): $(VSRC) $(VHDR) $(wildcard *.sdc)
	$(FPGA_ENV) && $(VIVADOPATH)/bin/vivado -nojournal -log vivado.log -mode batch -source vivado.tcl -tclargs $(NAME) $(TOP_MODULE) "$(VSRC)" $(FPGA_PART)
	LOG=vivado.log ../../sw/vivado2tex.sh
