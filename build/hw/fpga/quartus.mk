FPGA_OBJ:=$(TOP_MODULE)_0.qxp
FPGA_LOG:=quartus.log

FPGA_SERVER=$(QUARTUS_SERVER)
FPGA_USER=$(QUARTUS_USER)

ENV=$(QUARTUSPATH)/nios2eds/nios2_command_shell.sh

$(FPGA_OBJ): $(VHDR) $(VSRC) $(wildcard *.sdc)
	$(ENV) quartus_sh -t quartus.tcl $(TOP_MODULE) $(DEFINE) "$(VSRC)" $(FPGA_PART) $(NAME)
	$(ENV) quartus_map --read_settings_files=on --write_settings_files=off $(TOP_MODULE) -c $(TOP_MODULE)
	$(ENV) quartus_fit --read_settings_files=off --write_settings_files=off $(TOP_MODULE) -c $(TOP_MODULE)
	$(ENV) quartus_cdb --read_settings_files=off --write_settings_files=off $(TOP_MODULE) -c $(TOP_MODULE) --merge=on
	$(ENV) quartus_cdb $(TOP_MODULE) -c $(TOP_MODULE) --incremental_compilation_export=$(TOP_MODULE)_0.qxp --incremental_compilation_export_partition_name=Top --incremental_compilation_export_post_synth=on --incremental_compilation_export_post_fit=off --incremental_compilation_export_routing=on --incremental_compilation_export_flatten=on
	mv output_files/*.fit.summary $(FPGA_LOG)

test.log: $(FPGA_LOG)
	sed -e '1,3d' $< >> $@

