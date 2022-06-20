FPGA_OBJ=$(TOP_MODULE).edif
FPGA_LOG=vivado.log

FPGA_SERVER=$(VIVADO_SERVER)
FPGA_USER=$(VIVADO_USER)

ENV:= bash $(VIVADOPATH)/settings64.sh

$(FPGA_OBJ): $(VSRC) $(VHDR) $(wildcard *.sdc)
	$(ENV) && $(VIVADOPATH)/bin/vivado -nojournal -log vivado.log -mode batch -source vivado.tcl -tclargs $(TOP_MODULE)  $(DEFINE) "$(VSRC)" $(FPGA_PART) $(NAME)

test.log: $(FPGA_LOG)
	grep LUTs $< >> $@ && grep RAMB36 $< >> $@ && grep RAMB18 $< >> $@ && grep DSPs $< >> $@

