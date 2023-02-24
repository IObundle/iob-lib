set NAME [lindex $argv 0]

project_open -force $NAME -revision $NAME
create_timing_netlist -model slow
read_sdc
update_timing_netlist
#create_timing_summary -setup -panel_name "Summary (Setup)" -multi_corner
report_path -nworst 5 -multi_corner -file reports/timing_paths.txt
catch {delete_timing_netlist}

