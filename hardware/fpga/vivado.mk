FPGA_OBJ=iob_cache.edif
FPGA_LOG=vivado.log

CONSTRAINTS:=$(wildcard *.xdc)

FPGA_SERVER=$(VIVADO_SERVER)
FPGA_USER=$(VIVADO_USER)

ENV:= $(VIVADOPATH)/settings64.sh

$(FPGA_OBJ): $(VSRC) $(VHDR)
	$(ENV); $(VIVADOPATH)/bin/vivado -nojournal -log vivado.log -mode batch -source $(LIB_DIR)/hardware/fpga/vivado.tcl -tclargs $(TOP_MODULE) "$(VSRC)" "$(INCLUDE)" "$(DEFINE)" $(FPGA_PART)
