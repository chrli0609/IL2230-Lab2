remove_design -all
# set global libraries
source ./syn/scr/synopsys_dc.setup
#start most work from here

set SOURCE_DIR ./rtl;                # rtl code that should be synthesised
set SYN_DIR ./syn;                   # synthesis directory
set OUT_DIR ${SYN_DIR}/db;           # output files: netlist, sdf sdc etc.
set REPORT_DIR  ${SYN_DIR}/rpt;      # synthesis reports: timing, area, etc.
set PARAMS N-${PARAM_N},QM-${PARAM_QM},QN-${PARAM_QN}

# Design specific ls
# variables
if { $TOP_NAME eq ""} {
    set TOP_NAME fully_serial
}

# Read files
set hierarchy_files [split [read [open ${SOURCE_DIR}/${TOP_NAME}_hierarchy.txt r]] "\n"]

# read design files
foreach filename [lrange ${hierarchy_files} 0 end-1] {
    puts "${filename}"
    analyze -format sverilog -lib WORK "${SOURCE_DIR}/${filename}"
}

elaborate ${TOP_NAME} -param N=>${PARAM_N},QM=>${PARAM_QM},QN=>${PARAM_QN}
#enclosed segmented top
set_wire_load_mode segmented 
set_wire_load_model -name TSMC8K_Lowk_Aggresive
set_operating_condition NCCOM

source ${SYN_DIR}/scr/${TOP_NAME}_constraints.sdc

compile -map_effort medium

report_constraints > ${REPORT_DIR}/${TOP_NAME}_${PARAMS}_constratints.sdc
report_area > ${REPORT_DIR}/${TOP_NAME}_${PARAMS}_area.txt
report_cell > ${REPORT_DIR}/${TOP_NAME}_${PARAMS}_cells.txt
report_timing > ${REPORT_DIR}/${TOP_NAME}_${PARAMS}_timing.txt
report_power > ${REPORT_DIR}/${TOP_NAME}_${PARAMS}_power.txt

# foreach filename [lrange ${hierarchy_files} 0 end-1] {
#     set s ${filename}
#     regexp -indices "\\w\\." $s index;
#     set filen  [string range $s 0 [lindex $index 0]]
#     puts "${filen}"
#     
#     puts "${filename}"
#     current_design ${filen}
#     write_script > ../syn/db/${filen}.wscr
# }

# Export netlist
write -hierarchy -format ddc -output ${OUT_DIR}/${TOP_NAME}_${PARAMS}.ddc
write -hierarchy -format verilog -output ${OUT_DIR}/${TOP_NAME}_${PARAMS}.v
