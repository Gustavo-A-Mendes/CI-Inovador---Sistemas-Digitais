// Você pode usar barras duplas para comentários
// 1. Diretórios de Inclusão (onde o compilador procura arquivos chamados via `include)
+incdir+../src/includes
+incdir+../tb/headers

// 2. Definição de Macros Globais (equivalente a `define no código)
+define+DEBUG_MODE
+define+LARGURA_BUS=32

// 3. Arquivos de Design RTL (ordem geralmente não importa para compilação, mas importa para elaboração de pacotes SV)
../src/pacote_tipos.sv
../src/somador.sv
../src/ula.sv
../src/processador_top.sv

// 4. Arquivos de Testbench
../tb/tb_processador.sv