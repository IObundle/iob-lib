FPGA_LOG=vivado.log
CONSTRAINTS:=$(wildcard *.xdc)

FPGA_SERVER=$(VIVADO_SERVER)
FPGA_USER=$(VIVADO_USER)

ifeq ($(FPGA_FAMILY),XCKU)
FPGA_PART:=xcku040-fbva676-1-c
endif


include $(LIB)/hardware/fpga/fpga.mk

ENV:= $(VIVADOPATH)/settings64.sh

$(FPGA_OBJ): $(VSRC) $(VHDR)
	$(ENV); $(VIVADOPATH)/bin/vivado -nojournal -log vivado.log -mode batch -source $(LIB)/hardware/fpga/vivado.tcl -tclargs $(TOP_MODULE) "$(VSRC)" "$(INCLUDE)" "$(DEFINE)" $(FPGA_PART)
