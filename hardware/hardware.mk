#lib header
ifeq ($(filter $(LIB_DIR)/hardware/include/iob_lib.vh, $(VHDR)),)
INCLUDE+=$(incdir)$(LIB_DIR)/hardware/include
VHDR+=$(LIB_DIR)/hardware/include/iob_lib.vh
endif

#include lib modules
$(foreach p, $(LIB_HW_MODULES), $(eval LIB_HW_MODULES_DIRS+=$(shell find $(LIB_DIR) -name $p)))
$(foreach p, $(LIB_HW_MODULES_DIRS), $(eval include $p/hardware.mk))

