ifneq (LIB,$(filter LIB, $(MODULES)))

MODULES+=LIB

INCLUDE+=-I$(LIB_DIR)/software

endif
