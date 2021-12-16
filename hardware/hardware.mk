#add itself to MODULES list
MODULES+=$(shell make -C $(LIB_DIR) corename | grep -v make)

#header
INCLUDE+=$(incdir)$(LIB_DIR)/hardware/include
VHDR+=$(LIB_DIR)/hardware/include/iob_lib.vh
#verilog sources
$(foreach p, $(LIBVSRC), $(eval VSRC+=$p))
