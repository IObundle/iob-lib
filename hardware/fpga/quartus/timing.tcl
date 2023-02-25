set NAME [lindex $argv 0]
project_open -force $NAME -revision $NAME
create_timing_netlist -model slow
read_sdc
update_timing_netlist
report_path -nworst 5 -multi_corner -file reports/timing_paths.txt
report_path -min_path -file reports/min_path.txt
catch {delete_timing_netlist}

