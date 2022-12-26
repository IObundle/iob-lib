OUTPUT_DIR=results

SYN_SERVER=$(CADENCE_SERVER)
SYN_USER=$(CADENCE_USER)
SYN_SSH_FLAGS=$(CADENCE_SSH_FLAGS)
SYN_SCP_FLAGS=$(CADENCE_SCP_FLAGS)
SYN_SYNC_FLAGS=$(CADENCE_SYNC_FLAGS)

synth: $(VHDR) $(VSRC)
	$(GENUS_ENV); genus -batch -files run_genus.tcl

tsmc_cln28hpc-clean:
	@rm -rf fv results st_part_log

.PHONY: synth tsmc_cln28hpc-clean
