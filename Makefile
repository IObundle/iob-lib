# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile simulates the hardware modules in this repo
#

SHELL=bash
export

#build here
LIB_DIR:=.
BUILD_VSRC_DIR:=./hardware/src
BUILD_SIM_DIR:=.
REMOTE_BUILD_DIR:=$(USER)/iob-lib
REMOTE_SRC_DIR:=$(REMOTE_BUILD_DIR)/hardware/src

LINT_SERVER=$(SYNOPSYS_SERVER)
LINT_USER=$(SYNOPSYS_USER)
LINT_SSH_FLAGS=$(SYNOPSYS_SSH_FLAGS)
LINT_SCP_FLAGS=$(SYNOPSYS_SCP_FLAGS)
LINT_SYNC_FLAGS=$(SYNOPSYS_SYNC_FLAGS)

PYTHON_EXEC:=/usr/bin/env python3 -B

# Default module
MODULE ?= iob_ram_2p
MODULE_DIR ?= $(shell find hardware -name $(MODULE))
ifeq ($(MODULE_DIR),)
$(info No such module $(MODULE))
endif

# Defines
DEFINE=-DADDR_W=10 -DDATA_W=32

VCD?=0
ifeq ($(VCD),1)
DEFINE+= -DVCD
endif

# Includes
INCLUDE=-Ihardware/modules -Ihardware/src

# asymmetric memory present
IS_ASYM ?= 0

#default target
all: sim

#setup test directory
$(BUILD_VSRC_DIR):
	@mkdir $@

copy_srcs: $(BUILD_VSRC_DIR) 
	$(PYTHON_EXEC) ./scripts/lib_sim_setup.py $(MODULE) $(BUILD_VSRC_DIR)

# iverilog simulation
VLOG=iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE)

sim: copy_srcs
	set -e;
	@echo "Simulating module $(MODULE)"
ifeq ($(IS_ASYM),0)
	$(VLOG) -DW_DATA_W=8 -DR_DATA_W=8 $(wildcard $(BUILD_VSRC_DIR)/*.v) &&\
	./a.out $(TEST_LOG);
else
	$(VLOG) -DW_DATA_W=32 -DR_DATA_W=8 $(wildcard $(BUILD_VSRC_DIR)/*.v) &&\
	./a.out $(TEST_LOG) && if [ $(VCD) != 0 ]; then mv uut.vcd uut1.vcd; fi 
	$(VLOG) -DW_DATA_W=8 -DR_DATA_W=32 $(wildcard $(BUILD_VSRC_DIR)/*.v) &&\
	./a.out $(TEST_LOG) && if [ $(VCD) != 0 ]; then mv uut.vcd uut2.vcd; fi
	$(VLOG) -DW_DATA_W=8 -DR_DATA_W=8 $(wildcard $(BUILD_VSRC_DIR)/*.v) &&\
	./a.out $(TEST_LOG) && if [ $(VCD) != 0 ]; then mv uut.vcd uut3.vcd; fi
endif
ifeq ($(VCD),1)
ifeq ($(IS_ASYM),0)
	@if [ ! `pgrep gtkwave` ]; then gtkwave uut.vcd; fi &
else
	@if [ ! `pgrep gtkwave` ]; then gtkwave uut1.vcd; fi &
endif
endif

# Install board server and client
board_server_install:
	sudo cp scripts/board_client.py /usr/local/bin/ && \
	sudo cp scripts/board_server.py /usr/local/bin/ && \
	sudo cp scripts/board_server.service /etc/systemd/system/ && \
	sudo systemctl daemon-reload && \
	sudo systemctl restart board_server

board_server_uninstall:
	sudo systemctl stop board_server && \
	sudo systemctl disable board_server && \
	sudo rm /usr/local/bin/board_client.py && \
	sudo rm /usr/local/bin/board_server.py && \
	sudo rm /etc/systemd/system/board_server.service && \
	sudo systemctl daemon-reload

board_server_status:
	systemctl status board_server

format: verilog-lint verilog-format python-format clang-format

python-format:
	@./scripts/black_format.py

clang-format:
	@./scripts/clang_format.py

IOB_LIB_PATH=$(LIB_DIR)/scripts
export IOB_LIB_PATH

verilog-lint:
	$(IOB_LIB_PATH)/verilog-lint.sh `find hardware -type f -name "*.v"  | tr '\n' ' '`

verilog-format:
	$(IOB_LIB_PATH)/verilog-format.sh `find  hardware -type f -name "*.v"| tr '\n' ' '`


# Spyglass lint
lint-all:
	./scripts/lint_all.sh

lint-run: clean copy_srcs
	$(PYTHON_EXEC) ./scripts/lib_lint_setup.py $(MODULE)
	touch $(BUILD_VSRC_DIR)/$(MODULE).sdc
	rm -rf $(BUILD_VSRC_DIR)/*_tb.v
	cd $(BUILD_VSRC_DIR) && ls *.v >> $(MODULE)_files.list
	@echo "Linting module $(MODULE)"
ifeq ($(LINT_SERVER),)
	cd $(BUILD_VSRC_DIR) && (echo exit | spyglass -licqueue -shell -project spyglass.prj -goals "lint/lint_rtl")
else
	ssh $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --delete --exclude .git $(LINT_SYNC_FLAGS) . $(LINT_USER)@$(LINT_SERVER):$(REMOTE_BUILD_DIR)
	ssh -t $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) 'make -C $(REMOTE_BUILD_DIR) lint-run MODULE=$(MODULE)'
	mkdir -p spyglass_reports
	scp $(LINT_SCP_FLAGS) $(LINT_USER)@$(LINT_SERVER):$(REMOTE_SRC_DIR)/spyglass/consolidated_reports/$(MODULE)_lint_lint_rtl/*.rpt spyglass_reports/.
endif

# module test
test: verilog-lint verilog-format
	@./scripts/black_format.py --check
	@./scripts/clang_format.py --check
	./scripts/test.sh

clean:
	@rm -rf $(BUILD_VSRC_DIR)
	@rm -rf spyglass_reports
	@rm -f *.v *.vh *.c *.h *.tex *.rpt
	@rm -f *~ \#*\# a.out *.vcd *.pyc *.log

debug:

.PHONY: all setup sim \
	board_server_install \
	format-install-all format-install-python format-install-clang \
	format format-check \
	verilog-lint verilog-format \
	clean debug
