## ICARUS VERILOG:

# Compila e elabora 
iverilog [flags] arquivo_fonte.v testbench.v
# Principais flags:
#   -s nome_modulo_raiz:    força o top_level para aquele módulo.
#                           Exemplo: iverilog -s nome_do_modulo_raiz design.v tb_1.v tb_2.v
#   -o <arquivo>:   Define o nome do arquivo de saída. Se não for usado, o padrão gerado é a.out.
#                   Exemplo: iverilog -o sim.vvp design.v testbench.v
#   
#   -t <target>:    Define o tipo de saída. O padrão é vvp. Usar -t null é excelente para fazer apenas a 
#                   verificação de sintaxe sem gerar um arquivo de saída.
#                   Exemplo: iverilog -t null design.v
#
#   -I <diretorio>: Especifica um diretório para buscar arquivos incluídos via `include no seu código Verilog.
#                   Exemplo: iverilog -I ./src -o sim.vvp top.v
#
#   -y <diretorio>: Especifica um diretório de biblioteca. O compilador buscará automaticamente módulos não 
#                   definidos em arquivos .v dentro deste diretório.
#
#   -g2001, -g2005, -g2012: Força o uso de um padrão específico da linguagem Verilog/SystemVerilog. O -g2012 
#                           é essencial se você estiver usando recursos de SystemVerilog.
#                           Exemplo: iverilog -g2012 -o sim.vvp sv_design.sv
#
#   -Wall:          Habilita todos os avisos (warnings) de compilação. Fortemente recomendado para evitar   
#                   bugs silenciosos.
#
#   -c <arquivo_de_comandos>:   Lê uma lista de arquivos fonte a partir de um arquivo de texto. Útil para 
#                               projetos muito grandes.

# Casos práticos:

# Em cenários com múltiplos testes, usar a flag "-s" juntamente com o coringa "*.sv", que puxa todos os arquivos, de modo a dar atenção para apenas um teste por ver:
iverilog -g2012 -s tb_ula_simples -o sim.vvp *.sv

# Com o uso de arquivos de texto, contendo todos os arquivos de módulos e testbenches, utiliar flag "-s" junto com a flag "-c", que chama esse arquivo de texto:
iverilog -g2012 -c rtl_files.txt -s tb_ula_avancado

# Execução da Simulação .vpp:
vvp nome_executal_gerado
# Principais flags:
#   -n:                 Faz com que o simulador encerre a execução ao encontrar comandos como $stop no 
#                       código, em vez de abrir um prompt interativo. (Geralmente é o comportamento desejado 
#                       em automações).
#
#   -l <arquivo.log>:   Redireciona a saída do terminal (como mensagens de $display ou $monitor) para um 
#                       arquivo de log, além de mostrá-las na tela.
#                       Exemplo: vvp sim.vvp -l output.log
#
#   -fst, -lxt2:        Instrui o simulador a converter internamente o formato de onda gerado para FST ou 
#                       LXT2, que são arquivos muito menores e mais rápidos de carregar no GTKWave do que o 
#                       formato VCD padrão.

# GUI: Precisa ter gerado o dumpfile no arquivo compilado
gtkwave ondas.vcd

# Fluxo de Trabalho completo:
# 1. Compila o arquivo de design e o testbench com suporte a SystemVerilog
iverilog -g2012 -Wall -o sim.vvp somador.sv tb_somador.sv

# 2. Executa a simulação (que gera o arquivo ondas.vcd via $dumpvars)
vvp sim.vvp

# 3. Abre a interface gráfica para visualizar o resultado
gtkwave ondas.vcd

## ----------------------------------------------------------------------

## XCelium:

# Compilar código
xrun -compile {./arquivo1.sv} {./arquivo2.sv} {./arquivo3.sv} ...

# Compila e Elaborar a simulação, sem executar
xrun -elaborate -top {nome_modulo_do_top_level}
# Compila e Elaborar a simulação, sem executar, e cria a snapshot da simulação
xrun -elaborate -top {nome_modulo_do_top_level} -snapshot <nome_snapshot>

# Executa snapshot da elaboração atual:
xrun -run <nome_snapshot>

# ---

## XCelium: Compila, elabora e executa a simulação:
xrun -top {nome_modulo_do_top_level} {./arquivo1.sv} {./arquivo2.sv} {./arquivo3.sv} ...

# Flags úteis:
#   -clean:             Remove diretórios temporários e base de dados de compilações anteriores
#   -gui:               Abre interface gráfica SimVision para depuração visual e análise de waveform
#   -access <modos>:    Controla acesso dos objetos da simulação (Necessário para ver o waveform)
#
#             +r    ->  Leitura
#             +rw   ->  Leitura e Escrita
#             +rwc  ->  Leitura, Escrita e Conectividade (para debug completo e tracing de drivers)
#   
#   -debug:             Habilita recursos internos adicionais de debug e salva informações estruturais no banco de dados
#   -linedebug:         Debug linha por linha
#   -sv/ -v93/ -vhdl08: Compatibilidade com SystemVerilog, VHDL-93 ou VHDL 2008
#   -timescale:         Define uma escala de tempo padrão para módulos que não a possuam declarada
#   -64bit:             Invoca os binários do Xcelium em modo de 64 bits (necessário para designs grandes).


## VIVADO

# Gerar relatório de utilização (report-utilization)
report_utilization -file {caminho/ate/o/pasta/nome_arquivo.rpt}

# Gerar os arquivos .sdf e o netlist.v, referentes ao atraso físico, APÓS a etapa de roteamento (route_design) estar concluída. (Run Implementation)
write_sdf -force ./meu_projeto_atrasos.sdf
write_verilog -force -mode timesim -sdf_anno true ./meu_projeto_netlist.v
# OBS: Para a simulação fazer sentido fora do Vivado, você também precisa exportar a Netlist com os delays matematicamente vinculados ao SDF:



## Executando simulação com os arquivos de .sdf e netlist.v no XCelium:

# No testbench, chamar o arquivo .sdf:
# Argumentos: ("nome_do_arquivo.sdf", instancia_alvo, config_logs, ...)
$sdf_annotate("meu_projeto_atrasos.sdf", tb_top_level.DUT, , "sdf_log.txt", MAXIMUM);

# Rodar o testbench com atraso injetado do .sdf do Vivado:
xrun tb_top_level.sv meu_projeto_netlist.v $VIVADO_HOME/data/verilog/src/glbl.v -y $VIVADO_HOME/data/verilog/src/unisims -libext .v -access +rwc -gui

## XCelium: rodar o testbench com atraso injetado do .sdf do Vivado + flags para forçar o Xcelium alinhar o tratamento SDF entre as ferramentas
xrun tb_top_level.sv meu_projeto_netlist.v $VIVADO_HOME/data/verilog/src/glbl.v -y $VIVADO_HOME/data/verilog/src/unisims -libext .v -access +rwc -gui -sdf_nocheck_celltype -pulse_r 0 -pulse_e 0 -notimingchecks