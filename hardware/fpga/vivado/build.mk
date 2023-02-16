ifeq ($(IS_FPGA),1)
FPGA_OBJ=$(NAME)_fpga_wrapper.bit
else
FPGA_OBJ=$(NETLIST_NAME).edif
FPGA_STUB=$(NETLIST_NAME)_stub.v
endif

FPGA_LOG=vivado.log
NORUN=0

FPGA_SERVER=$(VIVADO_SERVER)
FPGA_USER=$(VIVADO_USER)
FPGA_ENV:= bash $(VIVADOPATH)/settings64.sh
FPGA_PROG=$(FPGA_ENV) && $(VIVADOPATH)/bin/vivado -nojournal -log vivado.log -mode batch -source vivado/prog.tcl -tclargs $(NAME)_fpga_wrapper

# work-around for http://svn.clifford.at/handicraft/2016/vivadosig11
export RDI_VERBOSE = False

$(FPGA_OBJ): $(VSRC) $(VHDR) $(IP) $(wildcard *.sdc)
	$(FPGA_ENV) && $(VIVADOPATH)/bin/vivado -nojournal -log vivado.log -mode batch -source vivado/build.tcl -tclargs $(NETLIST_NAME) $(BOARD) "$(VSRC)" "$(IP)" $(IS_FPGA) $(USE_EXTMEM)

vivado-clean:
	@rm -rf .Xil

.PHONY: vivado-clean
