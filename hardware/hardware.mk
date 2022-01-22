define GET_LIB_MODULE_DIR
$(shell find $(LIB_DIR) -name $(1))
endef

#lib header
ifeq ($(filter iob_lib.vh, $(VHDR)),)
INCLUDE+=$(incdir)$(LIB_DIR)/hardware/include
VHDR+=$(LIB_DIR)/hardware/include/iob_lib.vh
endif

#include lib modules
$(foreach p, $(LIB_MODULES), $(eval LIB_MODULES_DIRS+=$(call GET_LIB_MODULE_DIR, $p)))
$(foreach p, $(LIB_MODULES_DIRS), $(eval include $p/hardware.mk))

