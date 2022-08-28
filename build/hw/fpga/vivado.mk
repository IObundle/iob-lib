FPGA_OBJ=$(TOP_MODULE).edif
FPGA_TEX=vivado.tex
FPGA_SERVER=$(VIVADO_SERVER)
FPGA_USER=$(VIVADO_USER)

ENV:= bash $(VIVADOPATH)/settings64.sh

$(FPGA_OBJ): $(VSRC) $(VHDR) $(wildcard *.sdc)
	$(ENV) && $(VIVADOPATH)/bin/vivado -nojournal -log vivado.log -mode batch -source vivado.tcl -tclargs $(TOP_MODULE)  $(DEFINE) "$(VSRC)" $(FPGA_PART) $(NAME)
	LOG=vivado.log ../../sw/vivado2tex.sh

test.log: $(FPGA_OBJ)
	if [ -f $@ ]; then cp vivado.tex $@; else cat vivado.tex >> $@; fi


