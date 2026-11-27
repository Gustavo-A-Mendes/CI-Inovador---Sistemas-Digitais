set LOCAL_DIR   [file dirname [file normalize [info script]]]
set PROJECT_DIR [file normalize ${LOCAL_DIR}/..]
set TECH_NAME   "180nm"
set LIB_NAME    "osu018_stdcells"
set RTL_PATH    ${PROJECT_DIR}/src
set LIB_PATH    ${PROJECT_DIR}/library

# Define o nome do módulo de topo para a elaboração.
set DESIGN_NAME "ula"

# Seleciona o arquivo Library que descreve as células da condição rápida.
set LIB_FILE    ${LIB_NAME}.lib
# Guarda o nome do único arquivo RTL usado neste exemplo.
set FILE_LIST   ${DESIGN_NAME}.sv

# ===== Esforço de síntese =====
# Escolhe esforço alto para a síntese genérica da lógica RTL.
set SYN_EFFORT high
# Escolhe esforço alto para o mapeamento em células da biblioteca.
set MAP_EFFORT high
# Escolhe esforço alto para a otimização incremental da netlist.
set OPT_EFFORT high

# Guarda uma segunda cópia do nome do topo, reservada pelo template.
set TOP_MODULE  $DESIGN_NAME

set OUT_DIR ../outputs/${TECH_NAME}/
set RPT_DIR ../reports/${TECH_NAME}/

file mkdir $OUT_DIR
file mkdir $RPT_DIR

# ======================================================================
#   COMANDOS PARA O GENUS
# ======================================================================

# 1. Carregamento da biblioteca:
if {![file exists "${LIB_PATH}/${LIB_FILE}"]} {
    error "ERRO: Biblioteca nao encontrada em ${LIB_PATH}/${LIB_FILE}"
}

set_db init_lib_search_path $LIB_PATH
set_db library $LIB_FILE

# 2. Leitura e elaboração do RTL:
read_hdl -sv $RTL_PATH/$FILE_LIST
elaborate $TOP_MODULE
check_design -unresolved

# 3. Síntese Lógica (Genérica -> Mapeamento -> Otimização)
set_db syn_generic_effort $SYN_EFFORT
syn_generic
set_db syn_map_effort $MAP_EFFORT
syn_map
set_db syn_opt_effort $OPT_EFFORT
syn_opt

# 4. Abrir Interface
# gui_show

# 5. Relatórios de Área, Potência e Portas
report_area  > ${RPT_DIR}/report_area_${TECH_NAME}.rpt
report_power > ${RPT_DIR}/report_power_${TECH_NAME}.rpt
report_gates > ${RPT_DIR}/report_gates_${TECH_NAME}.rpt

# 6. Exportação do Verilog Netlist para GLS
write_hdl > ${OUT_DIR}/${TOP_MODULE}_netlist_${TECH_NAME}.v
write_sdf > ${OUT_DIR}/${TOP_MODULE}_atraso_${TECH_NAME}.sdf

# 7. Fechar o Genus
exit