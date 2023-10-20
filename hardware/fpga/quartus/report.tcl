set NAME [lindex $argv 0]

report_path -nworst 5 -multi_corner -file reports/$NAME.sta.paths
report_path -min_path -file reports/$NAME.sta.min_path
report_max_skew -file reports/$NAME.sta.skew
report_metastability -file reports/$NAME.sta.metastability
report_timing -setup -nworst 5 -detail full_path -file reports/$NAME.setup.sta.timing
report_timing -hold -nworst 5 -detail full_path -file reports/$NAME.hold.sta.timing

set setup_domain_list [get_clock_domain_info -setup]

# Report the Worst Case Setups slacks per clock
foreach domain $setup_domain_list {
    report_timing -nworst 5 -setup -to_clock [lindex $domain 0] -file reports/$NAME.$domain.setup.sta.timing
    report_timing -nworst 5 -hold -to_clock [lindex $domain 0] -file reports/$NAME.$domain.hold.sta.timing
}
