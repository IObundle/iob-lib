ifneq (LIB,$(filter LIB, $(SW_MODULES)))

SW_MODULES+=LIB

INCLUDE+=-I$(LIB_DIR)/software/include

endif
