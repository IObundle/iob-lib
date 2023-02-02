set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CGTFD9E5F35C7
set_global_assignment -name IOBANK_VCCIO 1.5V -section_id 4A

if { $USE_EXTMEM > 0 } {
	set_global_assignment -name QIP_FILE quartus/$BOARD/alt_ddr3.qip
}
