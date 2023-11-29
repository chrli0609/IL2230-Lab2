variable scriptPath [file normalize [info script]]
set rel [file dirname $scriptPath]
set TOP_NAME fully_serial

puts ${TOP_NAME}
puts ${rel}
set PARAM_N 2
set PARAM_QM 3
set PARAM_QN 5
source ${rel}/dc_synthesis.tcl
set PARAM_QM 6
set PARAM_QN 10
source ${rel}/dc_synthesis.tcl
set PARAM_QM 12
set PARAM_QN 20
source ${rel}/dc_synthesis.tcl


set PARAM_N 4
set PARAM_QM 3
set PARAM_QN 5
source ${rel}/dc_synthesis.tcl
set PARAM_QM 6
set PARAM_QN 10
source ${rel}/dc_synthesis.tcl
set PARAM_QM 12
set PARAM_QN 20
source ${rel}/dc_synthesis.tcl

set PARAM_N 8
set PARAM_QM 3
set PARAM_QN 5
source ${rel}/dc_synthesis.tcl
set PARAM_QM 6
set PARAM_QN 10
source ${rel}/dc_synthesis.tcl
set PARAM_QM 12
set PARAM_QN 20
source ${rel}/dc_synthesis.tcl

set PARAM_N 16
set PARAM_QM 3
set PARAM_QN 5
source ${rel}/dc_synthesis.tcl
set PARAM_QM 6
set PARAM_QN 10
source ${rel}/dc_synthesis.tcl
set PARAM_QM 12
set PARAM_QN 20
source ${rel}/dc_synthesis.tcl

set PARAM_N 32
set PARAM_QM 3
set PARAM_QN 5
source ${rel}/dc_synthesis.tcl
set PARAM_QM 6
set PARAM_QN 10
source ${rel}/dc_synthesis.tcl
set PARAM_QM 12
set PARAM_QN 20
source ${rel}/dc_synthesis.tcl

set PARAM_N 64
set PARAM_QM 3
set PARAM_QN 5
source ${rel}/dc_synthesis.tcl
set PARAM_QM 6
set PARAM_QN 10
source ${rel}/dc_synthesis.tcl
set PARAM_QM 12
set PARAM_QN 20
source ${rel}/dc_synthesis.tcl
