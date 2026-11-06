## XCelium: Compilar
xrun -compile []
## XCelium: Elaborar
xrun -elaborate -top []
## XCelium: Executar
xrun -top []





## Vivado: gerar relatório de utilização (report-utilization)
report_utilization -file {caminho/ate/o/pasta/nome_arquivo.rpt}

## Vivado: gerar os arquivos .sdf e o netlist.v, referentes ao atraso físico

# Este comando só funciona APÓS a etapa de roteamento (route_design) estar concluída.
write_sdf -force ./meu_projeto_atrasos.sdf

# Para a simulação fazer sentido fora do Vivado, você também precisa exportar a Netlist com os delays matematicamente vinculados ao SDF:
write_verilog -force -mode timesim -sdf_anno true ./meu_projeto_netlist.v

## XCelium: rodar o testbench com atraso injetado do .sdf do Vivado
xrun tb_top_level.sv meu_projeto_netlist.v $VIVADO_HOME/data/verilog/src/glbl.v -y $VIVADO_HOME/data/verilog/src/unisims -libext .v -access +rwc -gui

## XCelium: rodar o testbench com atraso injetado do .sdf do Vivado + flags para forçar o Xcelium alinhar o tratamento SDF entre as ferramentas
xrun tb_top_level.sv meu_projeto_netlist.v $VIVADO_HOME/data/verilog/src/glbl.v -y $VIVADO_HOME/data/verilog/src/unisims -libext .v -access +rwc -gui -sdf_nocheck_celltype -pulse_r 0 -pulse_e 0 -notimingchecks