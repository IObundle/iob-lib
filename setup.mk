
# core info
include $(CORE_DIR)/info.mk

# enable all flows in setup by default
SETUP_SW ?=1
SETUP_SIM ?=1
SETUP_FPGA ?=1
SETUP_DOC ?=1
SETUP_PPROC ?=1

# core internal paths
CORE_SW_DIR=$(CORE_DIR)/software
CORE_PC_DIR=$(CORE_SW_DIR)/pc-emul
CORE_HW_DIR=$(CORE_DIR)/hardware
CORE_SIM_DIR=$(CORE_HW_DIR)/simulation
CORE_FPGA_DIR=$(CORE_HW_DIR)/fpga
CORE_DOC_DIR=$(CORE_DIR)/document


# make version header
VERSION_STR:=$(shell software/python/version.py $(NAME) $(VERSION))

# establish build dir paths
BUILD_DIR := $(CORE_DIR)/$(NAME)_$(VERSION_STR)
BUILD_SW_DIR:=$(BUILD_DIR)/sw
BUILD_SW_SRC_DIR:=$(BUILD_DIR)/sw/src
BUILD_SW_PC_DIR:=$(BUILD_SW_DIR)/pc
BUILD_SW_EMB_DIR:=$(BUILD_SW_DIR)/emb
BUILD_VSRC_DIR:=$(BUILD_DIR)/hw/vsrc
BUILD_SIM_DIR:=$(BUILD_DIR)/hw/sim
BUILD_FPGA_DIR:=$(BUILD_DIR)/hw/fpga
BUILD_DOC_DIR:=$(BUILD_DIR)/doc
BUILD_TSRC_DIR:=$(BUILD_DOC_DIR)/tsrc
BUILD_FIG_DIR:=$(BUILD_DOC_DIR)/figures
BUILD_SYN_DIR:=$(BUILD_DIR)/hw/syn
BUILD_PPROC_DIR:=$(BUILD_DIR)/pproc
BUILD_PPROC_HW_DIR:=$(BUILD_PPROC_DIR)/hw
BUILD_PPROC_SW_EMB_DIR:=$(BUILD_PPROC_DIR)/sw/emb
BUILD_PPROC_SW_PC_DIR:=$(BUILD_PPROC_DIR)/sw/pc

# mkregs path
MKREGS:=build/sw/python/mkregs.py

# create build directory
$(BUILD_DIR):
	cp -r -u build $@

# import core hardware and simulation files
include $(CORE_DIR)/hardware/hardware.mk
include $(CORE_DIR)/hardware/simulation/sim_setup.mk

# import core software files
include $(CORE_DIR)/software/software.mk

# copy core version header file
VHDR+=$(BUILD_VSRC_DIR)/$(NAME)_version.vh
$(BUILD_VSRC_DIR)/$(NAME)_version.vh: $(NAME)_version.vh
	cp -u $< $@

# tex files requiring specific processing
tex_files:=deliverables config benefits results fpga_results asic_results features intro

setup: $(BUILD_DIR) $(VHDR) $(VSRC) $(HDR) $(SRC)
	echo "VERSION_STR=$(VERSION_STR)" > $(BUILD_DIR)/version.mk
	cp -u $(CORE_DIR)/info.mk $(BUILD_DIR)
ifneq ($(wildcard $(CORE_DIR)/mkregs.conf),)
	cp -u $(CORE_DIR)/mkregs.conf $(BUILD_TSRC_DIR)
endif
ifneq ($(SETUP_PC),0)
ifneq ($(wildcard $(CORE_PC_DIR)/*.expected),)
	cp -u $(CORE_PC_DIR)/*.expected $(BUILD_SW_PC_DIR)
endif
ifneq ($(wildcard $(CORE_PC_DIR)/pc-emul.mk),)
	cp -u $(CORE_PC_DIR)/pc-emul.mk $(BUILD_SW_PC_DIR)
endif
endif
ifneq ($(SETUP_SIM),0)
	cp -u $(CORE_SIM_DIR)/*.expected $(BUILD_SIM_DIR)
ifneq ($(wildcard $(CORE_SIM_DIR)/simulation.mk),)
	cp -u $(CORE_SIM_DIR)/simulation.mk $(BUILD_SIM_DIR)
endif
ifneq ($(wildcard $(CORE_SIM_DIR)/*_tb.*),)
	cp -u $(CORE_SIM_DIR)/*_tb.* $(BUILD_VSRC_DIR)
endif
endif
ifneq ($(SETUP_FPGA),0)
ifneq ($(wildcard $(CORE_FPGA_DIR)/*.mk),)
	cp -u $(CORE_FPGA_DIR)/*.mk $(BUILD_FPGA_DIR)
endif
	cp -u $(CORE_FPGA_DIR)/*.expected $(BUILD_FPGA_DIR)
ifneq ($(wildcard $(CORE_FPGA_DIR)/*.sdc),)
	cp -u $(CORE_FPGA_DIR)/*.sdc $(BUILD_FPGA_DIR)
endif
ifneq ($(wildcard $(CORE_FPGA_DIR)/*.xdc),)
	cp -u $(CORE_FPGA_DIR)/*.xdc $(BUILD_FPGA_DIR)
endif
endif
ifneq ($(SETUP_DOC),0)
ifneq ($(wildcard $(CORE_DOC_DIR)/*.mk),)
	cp -u $(CORE_DOC_DIR)/*.mk $(BUILD_DOC_DIR)
endif
	cp -f $(CORE_DOC_DIR)/*.tex $(BUILD_TSRC_DIR)
	cp -u $(CORE_DOC_DIR)/figures/* $(BUILD_FIG_DIR)
	$(foreach k, $(tex_files), if [ ! -f $(BUILD_TSRC_DIR)/$k.tex ] ; \
	then mv -u $(BUILD_TSRC_DIR)/$k_lib.tex $(BUILD_TSRC_DIR)/$k.tex; \
	else rm -f $(BUILD_TSRC_DIR)/$k_lib.tex; fi;)
endif
ifneq ($(SETUP_PPROC),0)
	cp -u $(VHDR) $(BUILD_PPROC_HW_DIR)
	cp -u $(VSRC) $(BUILD_PPROC_HW_DIR)
	make -C $(BUILD_PPROC_HW_DIR) build
	cp -u $(SW_EMB_SRC) $(BUILD_PPROC_SW_EMB_DIR)
	cp -u $(SW_EMB_HDR) $(BUILD_PPROC_SW_EMB_DIR)
	make -C $(BUILD_PPROC_SW_EMB_DIR) build
	cp -u $(SW_PC_SRC) $(BUILD_PPROC_SW_PC_DIR)
	cp -u $(SW_PC_HDR) $(BUILD_PPROC_SW_PC_DIR)
	make -C $(BUILD_PPROC_SW_PC_DIR) build
endif

.PHONY: version setup
