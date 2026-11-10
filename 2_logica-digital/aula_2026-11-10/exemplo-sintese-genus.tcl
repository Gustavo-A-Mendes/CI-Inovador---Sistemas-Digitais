# genus -no_gui -files script_genus.tcl
read_libs fast_vdd1v0_basicCells_hvt.lib
read_hdl -sv nome_arquivo_do_design.sv
elaborate
report_gates
syn_generic
syn_map
Gui_show # click com botão direito -> Schematic
report_timing -unconstrained
report_gates
report_sequential
# design hierarquico construído com células do meu design
write_netlist > detecta_padrao_serial_mapped.sv
#atrasos reais* calculados conforme cargas e interrelação entre as células selecionadas para o design
# *só vale para 1 caso de operação e será mais refinado na etapa de layout!
write_sdf > atrasos_meu_design.sdf