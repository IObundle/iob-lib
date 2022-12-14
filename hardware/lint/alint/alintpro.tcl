
set WS IOB_CORE_NAME_ws
set PRJ IOB_CORE_NAME_prj
set TOP IOB_CORE_NAME

if {![ file exists $WS.alintws ]} {
   workspace.create $WS
}
workspace.open $WS.alintws

if {![ file exists $PRJ.alintproj ]} {
   workspace.project.create $PRJ
}

workspace.project.open $PRJ.alintproj

puts "Reading files"


#includes
project.pref.vlogdirs -path verilog/

workspace.file.add -destination $PRJ -f $TOP_files.list


project.pref.toplevels -top $TOP

project.pref.vlogstandard -format sv2005


#project.policy.add -policy STARC_VLOG_ALL

project.run -project $PRJ

#project.parse
#project.elaborate
#project.constrain -clocks
#project.constrain -resets
#project.constrain -chip
#project.constrain 
source ../$TOP.sdc

project.run -project $PRJ

#project.lint
#Synth reports
project.report.synthesis -report synth.txt
project.report.violations -format simple_text -report violations.txt
project.report.violations -format pdf -report violations.pdf
project.report.quality -report qor.txt
