#extract cli args
set NAME [lindex $argv 0]
set BOARD [lindex $argv 1]
set VSRC [lindex $argv 2]
set DEFINES [lindex $argv 3]
set IP [lindex $argv 4]
set IS_FPGA [lindex $argv 5]
set USE_EXTMEM [lindex $argv 6]
set SEED [lindex $argv 7]

project_new $NAME -overwrite

if [project_exists $NAME] {
    project_open $NAME -force
} else {
    project_new $NAME
}

set_global_assignment -name TOP_LEVEL_ENTITY $NAME

#board data
source quartus/$BOARD/board.tcl

set_global_assignment -name PROJECT_OUTPUT_DIRECTORY reports
set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

#verilog heders search path
set_global_assignment -name SEARCH_PATH ../src
set_global_assignment -name SEARCH_PATH ./src

#quartus IPs
foreach q_file [split $IP \ ] {
    if { [ file extension $q_file ] == ".qsys" } {
        set_global_assignment -name QSYS_FILE $q_file
    }
}

#verilog macros
foreach macro [split $DEFINES \ ] {
    if {$macro != ""} {
        set_global_assignment -name VERILOG_MACRO $macro
    }
}

#verilog sources
foreach file [split $VSRC \ ] {
    if {$file != ""} {
        set_global_assignment -name VERILOG_FILE $file
    }
}



if {$IS_FPGA != "1"} {
    set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
    set_global_assignment -name PARTITION_NETLIST_TYPE POST_SYNTH -section_id $NAME:$NAME
    set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top
}


set_global_assignment -name SDC_FILE quartus/$BOARD/$NAME.sdc

set USE_QUARTUS_PRO 0

if { $BOARD == "DK-DEV-10CX220-A" || $BOARD == "DK-DEV-AGF014E2ES" } {
    set USE_QUARTUS_PRO 1
}

# random seed for fitting
set_global_assignment -name SEED $SEED

export_assignments

if {$USE_QUARTUS_PRO == 1} {

    if [catch {qexec "[file join $::quartus(binpath) quartus_syn] $NAME"} result] {
        qexit -error
    }

} else {
    if [catch {qexec "[file join $::quartus(binpath) quartus_map] $NAME"} result] {
        qexit -error
    }
}

if [file exists "quartus/postmap.tcl"] {
    source "quartus/postmap.tcl"
}
    

if [catch {qexec "[file join $::quartus(binpath) quartus_fit] $NAME"} result] {
    qexit -error
}

if [catch {qexec "[file join $::quartus(binpath) quartus_sta] $NAME"} result] {
    qexit -error
}

if [catch {qexec "[file join $::quartus(binpath) quartus_sta] -t quartus/timing.tcl $NAME"} result] {
    qexit -error
}

if {$IS_FPGA != "1"} {
    if [catch {qexec "[file join $::quartus(binpath) quartus_cdb] $NAME --incremental_compilation_export=$NAME.qxp --incremental_compilation_export_post_synth=on"} result] {
        qexit -error
    }
} else {
    if [catch {qexec "[file join $::quartus(binpath) quartus_asm] $NAME"} result] {
        qexit -error
    }
}

project_close
