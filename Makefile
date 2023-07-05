# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile simulates the hardware modules in this repo
#

LIB_DIR:=.
DISABLE_LINT:=1
DISABLE_FORMAT:=1
# Default lib module to setup. Can be overriden by the user.
TOP_MODULE_NAME ?=iob_ctls

include setup.mk


