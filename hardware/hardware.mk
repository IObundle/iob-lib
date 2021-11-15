#header
INCLUDE+=$(LIB_DIR)/include
#verilog sources
$(foreach p, $(LIBVSRC), $(eval VSRC+=$p))
