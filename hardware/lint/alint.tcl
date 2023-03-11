
set WS alint/IOB_CORE_NAME_ws
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
project.pref.vlogdirs -path ../src/

workspace.file.add -destination $PRJ -f IOB_CORE_NAME_files.list

# Open the sdc files for reading
set sdcfile1 [open "../syn/umc130/$TOP\_dev.sdc" "r"]
set sdcfile2 [open "../src/$TOP\_wrapper.sdc" "r"]
set sdcfile3 [open "../syn/$TOP\_tool.sdc" "r"]

# Open the output file for writing
set outfile [open "merged.sdc" "w"]

# Read the contents of the cdc files
set contents1 [read $sdcfile1]
set contents2 [read $sdcfile2]
set contents3 [read $sdcfile3]

# Write the contents of the sdc files to the output file
puts $outfile $contents1
puts $outfile $contents2
puts $outfile $contents3

# Close the input and output files
close $sdcfile1
close $sdcfile2
close $sdcfile3
close $outfile


workspace.file.add -destination $PRJ merged.sdc

project.pref.toplevels -top $TOP

project.pref.vlogstandard -format sv2005


#project.policy.add -policy STARC_VLOG_ALL

do ./alint_waiver.do

project.run -project $PRJ

#project.parse
#project.elaborate
#project.constrain -clocks
#project.constrain -resets
#project.constrain -chip
#project.constrain 
source merged.sdc

project.run -project $PRJ

#project.lint
#Synth reports
project.report.synthesis -report alint_synth.txt
project.report.violations -format simple_text -report alint_violations.txt
project.report.violations -format pdf -report alint_violations.pdf
project.report.quality -report alint_qor.txt

file delete $outfile
