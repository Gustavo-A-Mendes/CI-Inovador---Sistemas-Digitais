# genus -no_gui -files script_genus.tcl
read_libs ./library/fast_vdd1v0_basicCells_hvt.lib
read_hdl -sv ./src/decodificador_uart.sv

elaborate
report gates
syn_generic
syn_map

# click com botão direito -> Schematic
# Gui_show 
report timing -lint
# Exibe o relatório de temporização para os caminhos selecionados pelo Genus.
report timing
# Salva o relatório geral em counter_timing.rpt.
report timing -unconstrained > ./tb/report_timing.rpt
report gates > ./tb/report_gates.rpt
report sequential > ./tb/report_sequential.rpt

# design hierarquico construído com células do meu design
write_netlist > ./src/decodificador_uart_gates.v
# atrasos reais* calculados conforme cargas e interrelação entre as células selecionadas para o design
# *só vale para 1 caso de operação e será mais refinado na etapa de layout!
write_sdf > ./src/decodificador_uart_gates.sdf

exit