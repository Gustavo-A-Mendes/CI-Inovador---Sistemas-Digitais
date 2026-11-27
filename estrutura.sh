#!/usr/bin/env bash
# ==============================================================================
# criar_estrutura.sh
#
# Cria a pasta backend (e suas subpastas) dentro da pasta do projeto recebida do
# professor e GERA, dentro dela, os arquivos de síntese:
#
#   <projeto>/
#   ├── frontend/                       (já existe, vem do professor)
#   └── backend/
#       ├── layout/
#       └── synthesis/
#           ├── constraints/
#           ├── deliverables/
#           ├── reports/
#           ├── work/
#           └── scripts/
#               ├── run_first.sh
#               ├── <projeto>.tcl
#               └── common/
#                   ├── variables.tcl
#                   ├── path.tcl
#                   ├── tech.tcl
#                   ├── sdf_width_wa.etf
#                   └── script-report.tcl
#
# USO:
#   bash criar_estrutura.sh                 -> usa a pasta onde o script está salvo
#   bash criar_estrutura.sh /caminho/projeto -> usa a pasta informada
#
# O nome do projeto é o nome da pasta (ex.: multiplierFSM). Ele é usado para
# nomear o <projeto>.tcl e preencher DESIGNS no run_first.sh.
#
# Arquivos que já existem NÃO são sobrescritos (para não perder suas edições).
# Para sobrescrever tudo:  FORCE=1 bash criar_estrutura.sh
# ==============================================================================
set -euo pipefail

# ------------------------------------------------------------------------------
# Pasta do projeto e nome do projeto
# ------------------------------------------------------------------------------
if [[ $# -ge 1 ]]; then
    ROOT_DIR="$(cd "$1" && pwd)"
else
    ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
PROJECT_NAME="$(basename "${ROOT_DIR}")"   # <- edite aqui se o nome for outro

BACKEND_DIR="${ROOT_DIR}/backend"
SCRIPTS_DIR="${BACKEND_DIR}/synthesis/scripts"
COMMON_DIR="${SCRIPTS_DIR}/common"
FORCE="${FORCE:-0}"

DIRECTORIES=(
    "backend/layout"
    "backend/synthesis/constraints"
    "backend/synthesis/deliverables"
    "backend/synthesis/reports"
    "backend/synthesis/scripts"
    "backend/synthesis/scripts/common"
    "backend/synthesis/work"
)

echo "Projeto : ${PROJECT_NAME}"
echo "Pasta   : ${ROOT_DIR}"
if [[ ! -d "${ROOT_DIR}/frontend" ]]; then
    echo "AVISO   : pasta 'frontend' não encontrada em ${ROOT_DIR}"
fi

# ------------------------------------------------------------------------------
# Cria as pastas
# ------------------------------------------------------------------------------
echo
echo "Criando pastas..."
for directory in "${DIRECTORIES[@]}"; do
    mkdir -p "${ROOT_DIR}/${directory}"
    echo "  ${directory}"
done

# ------------------------------------------------------------------------------
# Auxiliar: devolve sucesso se o arquivo pode ser escrito
# ------------------------------------------------------------------------------
can_write() {
    if [[ -e "$1" && "${FORCE}" != "1" ]]; then
        echo "  [já existe, mantido] ${1#"${ROOT_DIR}"/}"
        return 1
    fi
    echo "  [criado] ${1#"${ROOT_DIR}"/}"
    return 0
}

echo
echo "Gerando arquivos..."

# ------------------------------------------------------------------------------
# scripts/run_first.sh
# PROJECT_DIR é preenchido com o caminho real da pasta do projeto.
# ------------------------------------------------------------------------------
if can_write "${SCRIPTS_DIR}/run_first.sh"; then
{
cat <<'EOF_RUN_FIRST_A'
#-----------------------------------------------------------------------------
# General design dependent variables
#-----------------------------------------------------------------------------
export DESIGNS="__PROJECT_NAME__" ;# put here the name of current design
export USER=aluno ;# put here YOUR user name at this machine
export COURSE= ;# put the course name or nothing
EOF_RUN_FIRST_A
printf 'export PROJECT_DIR="%s" ;# caminho da pasta do projeto (gerado por criar_estrutura.sh)\n' "${ROOT_DIR}"
cat <<'EOF_RUN_FIRST_B'
export BACKEND_DIR=${PROJECT_DIR}/backend
export TECH_DIR=/pdks ;# technology dependent
export LIB_DIR=${TECH_DIR}/gpdk045_v_6_0/gsclib045_all_v4_4/gsclib045/timing
export LEF_DIR=${TECH_DIR}/gpdk045_v_6_0/gsclib045_all_v4_4/gsclib045/lef
export HDL_NAME=${DESIGNS}
export RTL_FILES="${DESIGNS}.vhd" ;# put here all project rtl files 
export VLOG_LIST="$BACKEND_DIR/synthesis/deliverables/${DESIGNS}.v  $BACKEND_DIR/synthesis/deliverables/${DESIGNS}_io.v  $BACKEND_DIR/synthesis/deliverables/${DESIGNS}_chip.v"
#-----------------------------------------------------------------------------
# Custom Variables to be used in SDC (constraints file)
#-----------------------------------------------------------------------------
export MAIN_CLOCK_NAME=clk
export MAIN_RST_NAME=rst_n
export BEST_LIB_OPERATING_CONDITION=PVT_1P32V_0C ;# see LEF files
export WORST_LIB_OPERATING_CONDITION=PVT_0P9V_125C ;# see LEF files
export period_clk=100.0  ;# (100 ns = 10 MHz) (10 ns = 100 MHz) (2 ns = 500 MHz) (1 ns = 1 GHz)
export clk_uncertainty=0.05 ;# ns (“a guess”)
export clk_latency=0.10 ;# ns (“a guess”)
export in_delay=0.30 ;# ns
export out_delay=0.30;#ns 
export out_load=0.045 ;#pF 
export slew="146 164 264 252" ;#minimum rise, minimum fall, maximum rise and maximum fall 
export slew_min_rise=0.146 ;# ns
export slew_min_fall=0.164 ;# ns
export slew_max_rise=0.264 ;# ns
export slew_max_fall=0.252 ;# ns
#-----------------------------------------------------------------------------
# TECH Custom Variables to be used in technology loading (tech file)
#-----------------------------------------------------------------------------
export WORST_LIST="${LIB_DIR}/slow_vdd1v0_basicCells.lib"
export BEST_LIST="${LIB_DIR}/fast_vdd1v2_basicCells.lib"
export LEF_LIST="${LEF_DIR}/gsclib045_tech.lef ${LEF_DIR}/gsclib045_macro.lef"
export WORST_CAP_LIST="${TECH_DIR}/gpdk045_v_6_0/soce/gpdk045.basic.CapTbl"
export QRC_LIST="${TECH_DIR}/gpdk045_v_6_0/qrc/rcworst/qrcTechFile"
export CAP_MAX="${WORST_CAP_LIST}" ;# mmmc - layout tool .view file
export CAP_MIN="${WORST_CAP_LIST}" ;# mmmc - layout tool .view file
#-----------------------------------------------------------------------------
# POWER nets to be used in layout flow
#-----------------------------------------------------------------------------
export NET_ZERO=VSS ;# power net: see the lef file
export NET_ONE=VDD ;# power net: see the lef file
#-----------------------------------------------------------------------------
# CTS cells
#-----------------------------------------------------------------------------
export BUFFERS_CTS="CLKBUFX20 CLKBUFX16 CLKBUFX12 CLKBUFX8 CLKBUFX6 CLKBUFX4 CLKBUFX3 CLKBUFX2"
export INVERTERS_CTS="INVX20 CLKINVX20 INVX16 INVX12 INVX8 INVX6 INVX4 INVX3 INVX2 INVX1 INVXL"
#-----------------------------------------------------------------------------
# Placing core design pins (design dependent)
#-----------------------------------------------------------------------------
export LEFT_CORE_PINS="{a_i[0]} {a_i[1]} {a_i[2]} {a_i[3]} {a_i[4]} {a_i[5]} {a_i[6]} {a_i[7]}"
export TOP_CORE_PINS="{b_i[0]} {b_i[1]} {b_i[2]} {b_i[3]} {b_i[4]} {b_i[5]} {b_i[6]} {b_i[7]}"
export RIGHT_CORE_PINS="{sum_o[0]} {sum_o[1]} {sum_o[2]} {sum_o[3]} {sum_o[4]} {sum_o[5]} {sum_o[6]} {sum_o[7]}"
export BOTTOM_CORE_PINS="carry_i carry_o clk rst_n"

#-----------------------------------------------------------------------------
# Tool commands section
#-----------------------------------------------------------------------------
# loading modules
#module add cdn/ddi/ddi251
#module add cdn/xcelium/xcelium2509


# Para executar o XCELIUM
cd ${PROJECT_DIR}/frontend
### run HDL
#xrun -clean -64bit -v200x -v93 ${DESIGNS}.vhd Util_package.vhd ${DESIGNS}_tb.vhd -top ${DESIGNS}_tb -access +rwc -gui


# Para executar o GENUS
cd ${PROJECT_DIR}/backend/synthesis/work
## apenas o programa
#genus -abort_on_error -lic_startup Genus_Synthesis -lic_startup_options Genus_Physical_Opt -log genus -overwrite
# programa e carrega script para síntese automatizada
genus -abort_on_error -lic_startup Genus_Synthesis -lic_startup_options Genus_Physical_Opt -log genus -overwrite -files ${PROJECT_DIR}/backend/synthesis/scripts/${DESIGNS}.tcl
EOF_RUN_FIRST_B
} > "${SCRIPTS_DIR}/run_first.sh"
sed -i "s|^export DESIGNS=\"[^\"]*\"|export DESIGNS=\"${PROJECT_NAME}\"|" "${SCRIPTS_DIR}/run_first.sh"
fi

# ------------------------------------------------------------------------------
# scripts/<projeto>.tcl  (script principal de síntese)
# ------------------------------------------------------------------------------
if can_write "${SCRIPTS_DIR}/${PROJECT_NAME}.tcl"; then
cat > "${SCRIPTS_DIR}/${PROJECT_NAME}.tcl" <<'EOF_MAIN_TCL'


# Last update: 2026/03/08

#-----------------------------------------------------------------------------
# General Comments
#-----------------------------------------------------------------------------
puts "  "
puts "  "
puts "  "
puts "  "

#-----------------------------------------------------------------------------
# Load vriables set in run_first.tcl
#-----------------------------------------------------------------------------
source ../../synthesis/scripts/common/variables.tcl

#-----------------------------------------------------------------------------
# Load Path File
#-----------------------------------------------------------------------------
source ${PROJECT_DIR}/backend/synthesis/scripts/common/path.tcl

#-----------------------------------------------------------------------------
# Load Tech File
#-----------------------------------------------------------------------------
source ${SCRIPT_DIR}/common/tech.tcl
#set_db [get_db library_domain *best] .default true

#-----------------------------------------------------------------------------
# Analyze RTL source (manually set; file_list.tcl is not covered in ELC1054)
#-----------------------------------------------------------------------------
set_db init_hdl_search_path "${DEV_DIR} ${FRONTEND_DIR}"
read_hdl -language vhdl $RTL_FILES

#-----------------------------------------------------------------------------
# Elaborate Design
#-----------------------------------------------------------------------------
elaborate ${HDL_NAME}
set_top_module ${HDL_NAME}
check_design -unresolved ${HDL_NAME}
get_db current_design
check_library

#-----------------------------------------------------------------------------
# Constraints
#-----------------------------------------------------------------------------
# read_sdc ${BACKEND_DIR}/synthesis/constraints/${HDL_NAME}.sdc
report_timing -unconstrained
report timing -lint
gui_show

#-----------------------------------------------------------------------------
# Pos "Elaborate" Attributes (manually set)
#-----------------------------------------------------------------------------
set_db auto_ungroup none ;# (none|both) ungrouping will not be performed

#-----------------------------------------------------------------------------
# Generic optimization (technology independent)
#-----------------------------------------------------------------------------
syn_generic ${HDL_NAME} 

#-----------------------------------------------------------------------------
# Agressively optimization (area, timing, power) and mapping
#-----------------------------------------------------------------------------
syn_map ${HDL_NAME} 
get_db insts .base_cell.name -u ;# List all cell names used in the current design.

#-----------------------------------------------------------------------------
# Preparing and generating output data (reports, verilog netlist)
#-----------------------------------------------------------------------------
report_design_rules > ${RPT_DIR}/${HDL_NAME}_drc.rpt
report_area > ${RPT_DIR}/${HDL_NAME}_area.rpt ;# report_area -detail 
report_timing > ${RPT_DIR}/${HDL_NAME}_timing.rpt
report_gates > ${RPT_DIR}/${HDL_NAME}_gates.rpt
report_qor > ${RPT_DIR}/${HDL_NAME}_qor.rpt
source ../scripts/common/sdf_width_wa.etf
write_sdf -edge check_edge -nonegchecks -setuphold split -recrem split -version 3.0 -design ${HDL_NAME}  > ${DEV_DIR}/${HDL_NAME}_worst_SPLIT.sdf
write_hdl ${HDL_NAME} > ${DEV_DIR}/${HDL_NAME}.v





EOF_MAIN_TCL
fi

# ------------------------------------------------------------------------------
# scripts/common/variables.tcl
# ------------------------------------------------------------------------------
if can_write "${COMMON_DIR}/variables.tcl"; then
cat > "${COMMON_DIR}/variables.tcl" <<'EOF_VARIABLES'
#-----------------------------------------------------------------------------
# MAIN Custom Variables to be used by GENUS and INNOVUS (set in run_first.tcl)
#-----------------------------------------------------------------------------
set PROJECT_DIR $env(PROJECT_DIR)
set TECH_DIR $env(TECH_DIR)
set LEF_DIR $env(LEF_DIR)
set DESIGNS $env(DESIGNS)
set DESIGNS $env(DESIGNS)
set HDL_NAME $env(HDL_NAME)
set RTL_FILES $env(RTL_FILES)
set INTERCONNECT_MODE ple
# SDC related variables
set MAIN_CLOCK_NAME $env(MAIN_CLOCK_NAME)
set MAIN_RST_NAME $env(MAIN_RST_NAME)
set BEST_LIB_OPERATING_CONDITION $env(BEST_LIB_OPERATING_CONDITION)
set WORST_LIB_OPERATING_CONDITION $env(WORST_LIB_OPERATING_CONDITION)
set period_clk $env(period_clk)
set clk_uncertainty $env(clk_uncertainty)
set clk_latency $env(clk_latency)
set in_delay $env(in_delay)
set out_delay $env(out_delay)
set out_load $env(out_load)
set slew $env(slew)
set slew_min_rise $env(slew_min_rise)
set slew_min_fall $env(slew_min_fall)
set slew_max_rise $env(slew_max_rise)
set slew_max_fall $env(slew_max_fall)
# tech related variables
set WORST_LIST $env(WORST_LIST)
set BEST_LIST $env(BEST_LIST)
set LEF_LIST $env(LEF_LIST)
set WORST_CAP_LIST $env(WORST_CAP_LIST)
set QRC_LIST $env(QRC_LIST)
set CAP_MAX $env(CAP_MAX)
set CAP_MIN $env(CAP_MIN)
# power nets
set NET_ZERO $env(NET_ZERO)
set NET_ONE $env(NET_ONE)
# cts cells
set BUFFERS_CTS $env(BUFFERS_CTS)
set INVERTERS_CTS $env(INVERTERS_CTS)
# placing core design pins
set LEFT_CORE_PINS $env(LEFT_CORE_PINS)
set TOP_CORE_PINS $env(TOP_CORE_PINS)
set RIGHT_CORE_PINS $env(RIGHT_CORE_PINS)
set BOTTOM_CORE_PINS $env(BOTTOM_CORE_PINS)

EOF_VARIABLES
fi

# ------------------------------------------------------------------------------
# scripts/common/path.tcl
# ------------------------------------------------------------------------------
if can_write "${COMMON_DIR}/path.tcl"; then
cat > "${COMMON_DIR}/path.tcl" <<'EOF_PATH'

#-----------------------------------------------------------------------------
# Common path variables (directory structure dependent)
#-----------------------------------------------------------------------------
set BACKEND_DIR ${PROJECT_DIR}/backend
set SYNT_DIR ${BACKEND_DIR}/synthesis
set SCRIPT_DIR ${SYNT_DIR}/scripts
set RPT_DIR ${SYNT_DIR}/reports
set DEV_DIR ${SYNT_DIR}/deliverables
set LAYOUT_DIR ${BACKEND_DIR}/layout

#-----------------------------------------------------------------------------
# Setting rtl search directories
#-----------------------------------------------------------------------------
set FRONTEND_DIR ${PROJECT_DIR}/frontend
set OTHERS ""
lappend FRONTEND_DIR $OTHERS

#-----------------------------------------------------------------------------
# Setting technology directories
#-----------------------------------------------------------------------------
#set LIB_DIR ${TECH_DIR}/gsclib045_svt_v4.4/gsclib045/timing
lappend LIB_DIR ${TECH_DIR}/io

#set LEF_DIR ${TECH_DIR}/gsclib045_svt_v4.4/gsclib045/lef
lappend LEF_DIR ${TECH_DIR}/giolib045_v3.3/lef



EOF_PATH
fi

# ------------------------------------------------------------------------------
# scripts/common/tech.tcl
# ------------------------------------------------------------------------------
if can_write "${COMMON_DIR}/tech.tcl"; then
cat > "${COMMON_DIR}/tech.tcl" <<'EOF_TECH'

#-----------------------------------------------------------------------------
# Create Library Domain
#-----------------------------------------------------------------------------
create_library_domain {worst best} 
get_db library_domains *


#-----------------------------------------------------------------------------
# LEF Files and Technology Library
#-----------------------------------------------------------------------------
set_db lib_search_path "${LIB_DIR} ${LEF_DIR}"
set_db [get_db library_domains worst] .library ${WORST_LIST}
set_db [get_db library_domains best] .library ${BEST_LIST}


#-----------------------------------------------------------------------------
# Operating conditions
#-----------------------------------------------------------------------------
get_db [get_db library_domains *worst] .operating_conditions
set_db [get_db library_domains *worst] .operating_conditions ${WORST_LIB_OPERATING_CONDITION} ;# specifies the operating conditions to be used for timing
get_db [get_db library_domains *worst] .operating_conditions
#--
get_db [get_db library_domains *best] .operating_conditions
set_db [get_db library_domains *best] .operating_conditions ${BEST_LIB_OPERATING_CONDITION} ;# specifies the operating conditions to be used for timing
get_db [get_db library_domains *best] .operating_conditions
#--
get_db [get_db library_domain *worst] .default
get_db [get_db library_domain *best] .default 
#--
get_db [vfind /libraries -library_domain worst] .active_operating_conditions
get_db [vfind /libraries -library_domain best] .active_operating_conditions 
#--
#delete_obj [get_db library_domains *best]
#delete_obj [get_db library_domains *worst]



#-----------------------------------------------------------------------------
# LEF, QRC and CAP Files
#-----------------------------------------------------------------------------

# Load lef files
set_db lef_library ${LEF_LIST}


# Load cap table files
#set_db cap_table_file ${WORST_CAP_LIST}


# Load QRC tech files. OBS: Data from existing 'cap_table_file' is overwritten by technology file
set_db qrc_tech_file ${QRC_LIST}


# Use PLE mode
get_db interconnect_mode
set_db interconnect_mode ple ;# global




#-----------------------------------------------------------------------------
# Manage Cells
#-----------------------------------------------------------------------------
# Try to save power; gated clock cells
# No scan flip-flops
get_lib_cells
get_db lib_cells *SDFF*
get_db base_cell:SDFFRHQX1 .dont_use
set_db base_cell:SDFFRHQX1 .dont_use true
foreach lc [get_db base_cells -if {.name == "SDFF*"}] {
  get_db $lc .dont_use
  set_db $lc .dont_use true
}


foreach lc [get_db base_cells -if {.name == "TLATS*"}] {
  get_db $lc .dont_use
  set_db $lc .dont_use true
}



#-----------------------------------------------------------------------------
# Report important info
#-----------------------------------------------------------------------------
# To find libraries present in the library domain
get_db [get_db library_sets *worst] .libraries
get_db [get_db library_sets *best] .libraries
# To get all library cells from all the libraries present in the library domain
get_db [get_db library_sets *worst] .libraries.lib_cells
get_db [get_db library_sets *best] .libraries.lib_cells
# To get lib_cells only from a particular library in the library domain
get_db [get_db [get_db library_sets *worst] .libraries *slow_vdd1v0] .lib_cells
get_db [get_db [get_db library_sets *best] .libraries *fast_vdd1v2] .lib_cells 
# To find a particular lib_cell in the library domain 
get_db [get_db library_sets *worst] .libraries.lib_cells -regexp XOR
get_db [get_db library_sets *best] .libraries.lib_cells -regexp XOR
# To know all attributes of a particular lib_cell in a library domain in Common_UI
get_db [get_db [get_db library_sets *worst] .libraries.lib_cells -regexp CLKXOR2X1] .*



EOF_TECH
fi

# ------------------------------------------------------------------------------
# scripts/common/script-report.tcl
# ------------------------------------------------------------------------------
if can_write "${COMMON_DIR}/script-report.tcl"; then
cat > "${COMMON_DIR}/script-report.tcl" <<'EOF_REPORT'
proc get_lp_cells {} {
  global levelShifters
  set levelShifters ""
  global isoCells             
  set isoCells ""
  global clockGateCells  
  set clockGateCells ""
  global srpgCells        
  set srpgCells ""
  foreach lc [get_db lib_cells *] {
    if { [get_db $lc .is_level_shifter] == true } { lappend levelShifters $lc}
    if { [get_db $lc .is_isolation_cell] == true } { lappend isoCells $lc}     
    if { [get_db $lc .clock_gating_integrated_cell] != "" } { 
      lappend clockGateCells $lc
      switch [get_db $lc .clock_gating_integrated_cell] {
        generic { lappend generic $lc }
        latch_posedge { lappend lp $lc }
        latch_posedge_precontrol { lappend lppre $lc }
        latch_posedge_precontrol_obs { lappend lppreo $lc }
        latch_posedge_postcontrol { lappend lppost $lc }
        latch_posedge_postcontrol_obs { lappend lpposto $lc }
        latch_negedge { lappend ln $lc }
        latch_negedge_precontrol { lappend lnpre $lc }
        latch_negedge_precontrol_obs { lappend lnpreo $lc }
        latch_negedge_postcontrol { lappend lnpost $lc }
        latch_negedge_postcontrol_obs { lappend lnposto $lc } 
        ff_posedge { lappend fp $lc }
        ff_posedge_precontrol { lappend fppre $lc }
        ff_posedge_precontrol_obs { lappend fppreo $lc }
        ff_posedge_postcontrol { lappend fppost $lc }
        ff_posedge_postcontrol_obs { lappend fpposto $lc }
        ff_negedge { lappend fn $lc }
        ff_negedge_precontrol { lappend fnpre $lc }
        ff_negedge_precontrol_obs { lappend fnpreo $lc }
        ff_negedge_postcontrol { lappend fnpost $lc }
        ff_negedge_postcontrol_obs { lappend fnposto $lc }
        none_posedge { lappend np $lc }
        none_posedge_control { lappend npc $lc }
        none_posedge_control_obs { lappend npco $lc }
        none_negedge { lappend nn $lc }
        none_negedge_control { lappend nnc $lc }
        none_negedge_control_obs { lappend nnco $lc }
      }
    }
    if { [get_db $lc .power_gating_cell] == true } { lappend srpgCells $lc}  
  }

  puts "[llength $levelShifters] cells are identified as level shifters\n"
  puts "[llength $isoCells] cells are identified as pure isolation cells\n"     
  puts "[llength $clockGateCells] cells are identified as integrated clock gating cells:"
  if { [info exist lp] } { puts "    [llength $lp] of those use latch-based logic for posedge-triggered regs, without test-control" } 
  if { [info exist lppre] } { puts "    [llength $lppre] of those use latch-based logic for posedge-triggered registers, with test-control before the latch" }  
  if { [info exist lppreo] } { puts "    [llength $lppreo] of those use latch-based logic for posedge-triggered registers, with observable test-control before the latch" }
  if { [info exist lppost] } { puts "    [llength $lppost] of those use latch-based logic for posedge-triggered registers, with test-control after the latch" }
  if { [info exist lpposto] } { puts "    [llength $lpposto] of those use latch-based logic for posedge-triggered registers, with observable test-control after the latch" }
  if { [info exist ln] } { puts "    [llength $ln] of those use latch-based logic for negedge-triggered registers, without test-control" }
  if { [info exist lnpre] } { puts "    [llength $lnpre] of those use latch-based logic for negedge-triggered registers, with test-control before the latch" }
  if { [info exist lnpreo] } { puts "    [llength $lnpreo] of those use latch-based logic for negedge-triggered registers, with observable test-control before the latch" }
  if { [info exist lnpost] } { puts "    [llength $lnpost] of those use latch-based logic for negedge-triggered registers, with test-control after the latch" }
  if { [info exist lnposto] } { puts "    [llength $lnposto] of those use latch-based logic for negedge-triggered registers, with observable test-control after the latch" }
  if { [info exist fp] } { puts "    [llength $fp] of those use flop-based logic for posedge-triggered regs, without test-control" }
  if { [info exist fppre] } { puts "    [llength $fppre] of those use flop-based logic for posedge-triggered regs, with test-control before the flop" }
  if { [info exist fppreo] } { puts "    [llength $fppreo] of those use flop-based logic for posedge-triggered regs, with observable test-control before the flop" }
  if { [info exist fppost] } { puts "    [llength $fppost] of those use flop-based logic for posedge-triggered regs, with test-control after the flop" }
  if { [info exist fpposto] } { puts "    [llength $fpposto] of those use flop-based logic for posedge-triggered regs, with observable test-control after the flop" }
  if { [info exist fn] } { puts "    [llength $fn] of those use flop-based logic for negedge-triggered regs, without test-control" }
  if { [info exist fnpre] } { puts "    [llength $fnpre] of those use flop-based logic for negedge-triggered regs, with test-control before the flop" }
  if { [info exist fnpreo] } { puts "    [llength $fnpreo] of those use flop-based logic for negedge-triggered regs, with observable test-control before the flop" }
  if { [info exist fnpost] } { puts "    [llength $fnpost] of those use flop-based logic for negedge-triggered regs, with test-control after the flop" }
  if { [info exist fnposto] } { puts "    [llength $fnposto] of those use flop-based logic for negedge-triggered regs, with observable test-control after the flop" }
  if { [info exist np] } { puts "    [llength $np] of those use latch-free logic for posedge-triggered regs, without test-control" }
  if { [info exist npc] } { puts "    [llength $npc] of those use latch-free logic for posedge-triggered regs, with test-control" } 
  if { [info exist npco] } { puts "    [llength $npco] of those use latch-free logic for posedge-triggered regs, with observable test-control" } 
  if { [info exist nn] } { puts "    [llength $nn] of those  use latch-free logic for negedge-triggered regs, without test-control" } 
  if { [info exist nnc] } { puts "    [llength $nnc] of those  use latch-free logic for negedge-triggered regs, with test-control" } 
  if { [info exist nnco] } { puts "    [llength $nnco] of those  use latch-free logic for negedge-triggered regs, with observable test-control" } 
  if { [info exist generic] } { puts "    [llength $generic] of those have their functionality inferred from the Liberty state table" }  
  puts "\n[llength $srpgCells] cells are identified as SRPG cells\n"
}
EOF_REPORT
fi

# ------------------------------------------------------------------------------
# scripts/common/sdf_width_wa.etf
# Arquivo criptografado da Cadence (#pragma protect), com final de linha CRLF.
# Está embutido em base64 para ser restaurado byte a byte.
# ------------------------------------------------------------------------------
if can_write "${COMMON_DIR}/sdf_width_wa.etf"; then
base64 -d > "${COMMON_DIR}/sdf_width_wa.etf" <<'EOF_ETF'
I3ByYWdtYSBwcm90ZWN0IGJlZ2luX3Byb3RlY3RlZA0KI3ByYWdtYSBwcm90ZWN0IGVuY3J5cHRf
YWdlbnQ9Ik5DUFJPVEVDVCINCiNwcmFnbWEgcHJvdGVjdCBlbmNyeXB0X2FnZW50X2luZm89IkVu
Y3J5cHRlZCB1c2luZyBBUEkiDQojcHJhZ21hIHByb3RlY3Qga2V5X2tleW93bmVyPUNhZGVuY2Ug
RGVzaWduIFN5c3RlbXMuDQojcHJhZ21hIHByb3RlY3Qga2V5X2tleW5hbWU9cHJ2KENEU19SU0Ff
S0VZX1ZFUl8xKQ0KI3ByYWdtYSBwcm90ZWN0IGtleV9tZXRob2Q9UlNBDQojcHJhZ21hIHByb3Rl
Y3Qga2V5X2Jsb2NrDQpLcEdUY3pld2JpUnNmeUdVR1p0Zm9qcXhYY0FuRVdiRHhZbWFSM3dhQUIy
K0RpV3l2K1FXYlhYa3IvNU50REVhDQo3VW5qOWptbWZiZDdpVGJRVU5qbFRkZ1NyMkU3TG5VdlVi
N1U1enZyOGVzQXNtb3RISm1FVVI0WDFKbE9xOUo0DQp4UzFRZHlKN3dZcGQ4WmZNK1ZGQ3VmRE54
eHg5MkQySlhZVnJGUXlSeHhWMTIyL1k2clJvV0VPd3g2Q1VNSFFPDQpkWGJXVzFxK3JSSThhcWFZ
ajc1L1BIZmR3Nk9UT2orN0N2OFdod25yOG1IYTZUMTVoSWNWYm5xTmErQ2JDYnNhDQpuMEoxMnht
Qm01WktqV2h0MzNHTU5VelNuekNhMjBUMEFMVEg5VnpaNWZqSWdMSHhQVVFXbU1IMTNqWnlRUzRK
DQovaVpaQUJHczlGVHBvWDhCRVZSMHFRPT0NCiNwcmFnbWEgcHJvdGVjdCBlbmRfa2V5X2Jsb2Nr
DQojcHJhZ21hIHByb3RlY3QgZGlnZXN0X2Jsb2NrDQowRXo2eEZxby9nVHVRYm5pV2xIRFV4OEVt
YUk9DQojcHJhZ21hIHByb3RlY3QgZW5kX2RpZ2VzdF9ibG9jaw0KI3ByYWdtYSBwcm90ZWN0IGRh
dGFfYmxvY2sNClFjRHh0bDlqYWhLejY5c2dVQ1R1STNOK2pPckh0WXA2WStLb2pxOGhhVkRMWVll
dnd1elBtdnp3UHczeE04OHcNCm9mdncrV1BLalowamNaZHF6ck1Ec2ZuZmk1R0wyenpnZDd2VVVD
dnE3K1o1SUkwczlsMXEyOEd6cUtLK05ETUoNCkt4dUk1cklOcmY5bXJyTFRRU25nMXh1eFN2WGxQ
ODExTkQrZUk5NXY4RFhLNnVVSHoxNHYxb2pHM2c1N2pxcEENCktjNDdoTXF3REtiSWk1TkhRWGZB
cnhBV2I3dVkvSnBqOXYyMzRraGp5Yk9tTUliQ1dmT0pWRTkrOWZaZXpyMEkNCmUyUmlXdkNsRXFu
aVhBT2VRb09CMEVpdG1JU1FYanYwM09pL0RJVUpmME9EL0NhVzkrTW9XTmhlZXU1cXIxMnQNCnlt
b3l6TlYyUVVOckxpYWlTb01tcEZGYVV4SVUxTVBCa3ppZkYwVnN3TnBFbTA1YzV5QXlKajhGZi9T
c3czN0INCk15OTEwUHlpbHh5dDJYTkd5cWtJNVE9PQ0KI3ByYWdtYSBwcm90ZWN0IGVuZF9kYXRh
X2Jsb2NrDQojcHJhZ21hIHByb3RlY3QgZGlnZXN0X2Jsb2NrDQp3RitlMTM4L3ZTdE9VZjRtZlR6
QlY4V1ZNY289DQojcHJhZ21hIHByb3RlY3QgZW5kX2RpZ2VzdF9ibG9jaw0KI3ByYWdtYSBwcm90
ZWN0IGVuZF9wcm90ZWN0ZWQNCg==
EOF_ETF
fi

# ------------------------------------------------------------------------------
# O Git não versiona pastas vazias: coloca um marcador (pass.txt) apenas nas
# pastas que ficaram vazias.
# ------------------------------------------------------------------------------
for directory in "${DIRECTORIES[@]}"; do
    target="${ROOT_DIR}/${directory}"
    if [[ -z "$(ls -A "${target}")" ]]; then
        cat > "${target}/pass.txt" <<EOF
Pasta: ${directory}
Arquivo marcador para manter esta pasta no Git.
EOF
    fi
done

echo
echo "Estrutura criada com sucesso!"
echo "Backend em: ${BACKEND_DIR}"