#extract cli args
set TOP [lindex $argv 0]
set DEFINE [lindex $argv 1]
set VSRC [lindex $argv 2]
set PART [lindex $argv 3]
set NAME [lindex $argv 4]

#verilog sources
foreach file [split $VSRC \ ] {
    puts $file
    if {$file != "" && $file != " " && $file != "\n"} {
        read_verilog -sv $file
    }
}

set_property part $PART [current_project]

synth_design -include_dirs ../vsrc -verilog_define $DEFINE -part $PART -top $TOP -mode out_of_context -flatten_hierarchy none -verbose

read_xdc ../fpga/$NAME.xdc

opt_design
place_design
route_design

report_utilization
report_timing
report_clocks

write_edif -force $TOP.edif
set TOP_STUB $TOP
append TOP_STUB "_stub"
write_verilog -force -mode synth_stub $TOP_STUB.v
