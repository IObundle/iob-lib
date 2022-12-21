# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This file is run as a makefile to setup a delivery directory for an IP core
#

SHELL=bash
export

# include core delivery configuration
LIB_DIR=submodules/LIB
include config_setup.mk

# python scripts directory
PYTHON_DIR=$(LIB_DIR)/scripts

# create version string
VERSION_STR := $(shell $(PYTHON_DIR)/version.py -i .)

# delivery directory name
DELIVERY_DIR_NAME:=$(NAME)_$(VERSION_STR)

# establish delivery dir paths
DELIVERY_DIR := ../$(DELIVERY_DIR_NAME)

DELIVERY_VSR_DIR := $(DELIVERY_DIR)/hardware/src
DELIVERY_SIM_DIR := $(DELIVERY_DIR)/hardware/simulation

# build dir
BUILD_DIR_NAME:=$(NAME)_$(VERSION_STR)_build
BUILD_DIR := ../$(BUILD_DIR_NAME)


DELIVERY_SRC=$(shell find $(DELIVERY_DIR) -type f \( -name \*.v -o -name \*.vh \))
DELIVERY_MKFL=$(shell find $(DELIVERY_DIR) -type f \( -name \Makefile -o -name \*.mk \))
DELIVERY_TCL=$(shell find $(DELIVERY_DIR) -type f -name *.tcl)
DELIVERY_SDC=$(shell find $(DELIVERY_DIR) -type f -name *.sdc)

delivery: delivery-clean $(DELIVERY_DIR) delivery-doc

$(DELIVERY_DIR):
	@rsync -avz --exclude document --exclude lint $(BUILD_DIR)/. $@
	cp $(LIB_DIR)/delivery_build.mk $@/Makefile
	mv $@/config_delivery.mk $@/config.mk
	rm -f $@/config_build.mk
	ls -R $@ >> $@/README
	sed -i -e 's/\.\.\///' $@/README
	make -f submodules/LIB/delivery.mk insert_headers
	tar cvzf $(DELIVERY_DIR).tgz $(DELIVERY_DIR)
	
insert_headers:
	insert_header.py '//' $(DELIVERY_SRC) 
	insert_header.py '#'  $(DELIVERY_MKFL)
	insert_header.py '#'  $(DELIVERY_TCL)
	insert_header.py '#'  $(DELIVERY_SDC)
	insert_header.py '#'  $(DELIVERY_DIR)/README

delivery-doc:
	mkdir -p $(DELIVERY_DIR)/document
	cp $(BUILD_DIR)/document/$(NAME)_usg.pdf $(DELIVERY_DIR)/document/.

delivery-clean:
	rm -rf $(DELIVERY_DIR) $(DELIVERY_DIR).tgz



.PHONY: delivery delivery-clean
