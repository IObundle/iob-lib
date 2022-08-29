#extract cli args
set NAME [lindex $argv 0]
set TOP [lindex $argv 1]
set VSRC [lindex $argv 2]
set PART [lindex $argv 3]

#verilog sources
foreach file [split $VSRC \ ] {
    puts $file
    if {$file != "" && $file != " " && $file != "\n"} {
        read_verilog -sv $file
    }
}

set_property part $PART [current_project]

synth_design -include_dirs ../vsrc -part $PART -top $TOP -mode out_of_context -flatten_hierarchy none -verbose

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
