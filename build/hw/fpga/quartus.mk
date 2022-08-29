FPGA_OBJ:=$(TOP_MODULE)_0.qxp
FPGA_TEX:=quartus.tex
FPGA_SERVER=$(QUARTUS_SERVER)
FPGA_USER=$(QUARTUS_USER)
FPGA_ENV=$(QUARTUSPATH)/nios2eds/nios2_command_shell.sh

#map, fit, sta and cbd should be moved into quartus.tcl and removed from here
$(FPGA_OBJ): $(VHDR) $(VSRC) $(wildcard *.sdc)
	$(FPGA_ENV) quartus_sh -t quartus.tcl $(NAME) $(TOP_MODULE) "$(VSRC)" $(FPGA_PART)
	$(FPGA_ENV) quartus_map --read_settings_files=on --write_settings_files=off $(TOP_MODULE) -c $(TOP_MODULE)
	$(FPGA_ENV) quartus_fit --read_settings_files=off --write_settings_files=off $(TOP_MODULE) -c $(TOP_MODULE)
	$(FPGA_ENV) quartus_sta $(TOP_MODULE) -c $(TOP_MODULE) --do_report_timing
	$(FPGA_ENV) quartus_cdb --read_settings_files=off --write_settings_files=off $(TOP_MODULE) -c $(TOP_MODULE) --merge=on
	$(FPGA_ENV) quartus_cdb $(TOP_MODULE) -c $(TOP_MODULE) --incremental_compilation_export=$(TOP_MODULE)_0.qxp --incremental_compilation_export_partition_name=Top --incremental_compilation_export_post_synth=on --incremental_compilation_export_post_fit=off --incremental_compilation_export_routing=on --incremental_compilation_export_flatten=on
	LOG=output_files/*.fit.summary ../../sw/quartus2tex.sh

