#extract cli args
set NAME [lindex $argv 0]
set BOARD [lindex $argv 1]
set VSRC [lindex $argv 2]
set DEFINES [lindex $argv 3]
set VIP [lindex $argv 4]
set IS_FPGA [lindex $argv 5]
set CUSTOM_ARGS [lindex $argv 6]

puts $NAME
puts $BOARD
puts $VSRC
puts $DEFINES
puts $VIP
puts $IS_FPGA
puts $CUSTOM_ARGS


#verilog sources
foreach file [split $VSRC \ ] {
    puts $file
    if {$file != "" && $file != " " && $file != "\n"} {
        read_verilog -sv $file
    }
}

#vivado IPs
foreach file [split $VIP \ ] {
    puts $file
    if { [ file extension $file ] == ".edif" } {
        read_edif $file
    }
}

#read board propreties
source vivado/$BOARD/board.tcl

#set FPGA device
set_property part $PART [current_project]


#set custom assignments
if {[file exists "vivado/custom_build.tcl"]} {
    source "vivado/custom_build.tcl"
}

#
# Flow
#

if { $IS_FPGA == "1" } {
#read design constraints
    read_xdc vivado/$BOARD/$NAME\_dev.sdc
    read_xdc ./src/$NAME.sdc
    synth_design -include_dirs ../src -include_dirs ./src -verilog_define $DEFINES -part $PART -top $NAME -verbose
} else {
#read design constraints
    read_xdc -mode out_of_context vivado/$BOARD/$NAME\_dev.sdc
    read_xdc -mode out_of_context ./src/$NAME.sdc
    synth_design -include_dirs ../src -include_dirs ./src -verilog_define $DEFINES -part $PART -top $NAME -mode out_of_context -flatten_hierarchy rebuilt -verbose
}

set_property HD.PARTPIN_RANGE SLICE_X0Y0:SLICE_X29Y29 [all_inputs]
set_property HD.PARTPIN_RANGE SLICE_X0Y0:SLICE_X29Y29 [all_outputs]

set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports clk_i]
set_property HD.CLK_SRC BUFGCTRL_X0Y1 [get_ports mclk_i]
set_property HD.CLK_SRC BUFGCTRL_X0Y2 [get_ports btxclk_i]
set_property HD.CLK_SRC BUFGCTRL_X0Y3 [get_ports brxclk_i]
set_property ASYNC_REG TRUE [get_cells -hier {sync*[*]}]
set_property ASYNC_REG TRUE [get_cells -hier {signal_o*[*]}]
set_property HD.PARTITION 1 [current_design]



opt_design

place_design

route_design -timing

report_clocks
report_clock_interaction
report_cdc -details

file mkdir reports
report_clocks -file reports/$NAME\_$PART\_clocks.rpt
report_clock_interaction -file reports/$NAME\_$PART\_clock_interaction.rpt
report_cdc -details -file reports/$NAME\_$PART\_cdc.rpt
report_synchronizer_mtbf -file reports/$NAME\_$PART\_synchronizer_mtbf.rpt
report_utilization -file reports/$NAME\_$PART\_utilization.rpt
report_timing -file reports/$NAME\_$PART\_timing.rpt
report_timing_summary -file reports/$NAME\_$PART\_timing_summary.rpt
report_timing -file reports/$NAME\_$PART\_timing_paths.rpt -max_paths 30


if { $IS_FPGA == "1" } {
    write_bitstream -force $NAME.bit
} else {
    write_verilog -force $NAME\_netlist.v
    write_verilog -force -mode synth_stub ${NAME}_stub.v
}
