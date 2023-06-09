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


#default target
all: sim

#setup simulation directory
SIMULATOR?=icarus
NAME=$(MODULE)
include hardware/simulation/$(SIMULATOR).mk

VSRC=$(BUILD_VSRC_DIR)/*.v

$(BUILD_VSRC_DIR):
ifneq ($(SIM_SERVER),)
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $@ ]; then mkdir -p $@; fi"
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $@ ]; then mkdir -p $@/../simulation; fi"
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) "if [ ! -d ./scripts ]; then mkdir -p ./scripts; fi"
else
	@mkdir $@
endif


copy_srcs: $(BUILD_VSRC_DIR) 
	$(PYTHON_EXEC) ./scripts/lib_sim_setup.py $(MODULE) $(BUILD_VSRC_DIR)
ifneq ($(SIM_SERVER),)
	rsync $(SIM_SYNC_FLAGS) -avz --force --delete . $(SIM_USER)@$(SIM_SERVER):./iob-lib
endif 

sim-run: copy_srcs 
ifeq ($(SIM_SERVER),)
	set -e;
	@echo "Simulating module $(MODULE)"
	make exec 
ifeq ($(VCD),1)
	@if [ ! `pgrep gtkwave` ]; then gtkwave uut.vcd; fi &
endif
else
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'cd ./iob-lib; make $@ MODULE=$(MODULE) SIMULATOR=$(SIMULATOR)'
endif

sim-build: copy_srcs
ifeq ($(SIM_SERVER),)
	make comp
else
	ssh -t $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'cd iob-lib && make $@ MODULE=$(MODULE) SIMULATOR=$(SIMULATOR)'
endif


sim-waves: uut.vcd
	@if [ ! `pgrep gtkwave` ]; then gtkwave uut.vcd; fi &

uut.vcd:
	make sim VCD=1 MODULE=$(MODULE)

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

gen-clean:
	@rm -rf $(BUILD_VSRC_DIR)
	@rm -rf spyglass_reports
	@rm -f *.v *.vh *.c *.h *.tex *.rpt
	@rm -f *~ \#*\# a.out *.vcd *.pyc *.log
ifneq ($(SIM_SERVER),)
	ssh -t $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'if [ -d iob-lib ]; then cd iob-lib && make gen-clean; fi'
endif

debug:

.PHONY: all setup sim \
	board_server_install \
	format format-check \
	verilog-lint verilog-format \
	gen-clean debug
