include $(LIB_DIR)/config.mk

#add itself to MODULES list
MODULES+=$(MODULE)

#header
INCLUDE+=$(LIB_DIR)/hardware/include
#verilog sources
$(foreach p, $(LIBVSRC), $(eval VSRC+=$p))
