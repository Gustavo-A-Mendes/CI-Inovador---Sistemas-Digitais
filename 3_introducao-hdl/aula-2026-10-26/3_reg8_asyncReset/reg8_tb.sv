`timescale 1ns/1ps

module reg8_tb;

  // Sinais de teste
  logic       clk;
  logic       rst;
  logic [7:0] d;
  logic [7:0] q;

  // Instância do DUT
  reg8 dut (
      .clk(clk),
      .rst(rst),
      .d  (d),
      .q  (q)
  );

  // Geração do Clock (período de 10ns = 100MHz)
  always #5 clk = ~clk;

  // Sequência de Testes
  initial begin
    // Arquivo de ondas para visualização
    $dumpfile("reg8.vcd");
    $dumpvars(0, reg8_tb);

    // Inicialização dos sinais
    clk = 0;
    rst = 1;      // Começa com reset ativo
    d   = 8'h00;

    // Monitoramento contínuo das alterações
    $monitor("[%0t] clk = %b | rst = %b | d = 0x%h (%b) | q = 0x%h (%b)", 
             $time, clk, rst, d, d, q, q);

    // ----------------------------------------------------
    // 1. Aplicação do Reset Síncrono
    // ----------------------------------------------------
    #2 d = 8'hFF; // Tenta carregar 0xFF enquanto rst estã ativo
    
    @(posedge clk);
    #1; // q deve permanecer 0x00 pois rst = 1 na borda de subida

    // ----------------------------------------------------
    // 2. Liberação do Reset e Carga de Dados
    // ----------------------------------------------------
    @(negedge clk);
    rst = 0;      // Desativa o reset na borda de descida
    d   = 8'hA5;  // 10100101

    @(posedge clk);
    #1; // q deve ser atualizado para 0xA5

    // ----------------------------------------------------
    // 3. Alteração de 'd' sem Borda de Clock
    // ----------------------------------------------------
    #3 d = 8'h3C; // 00111100
    #2;           // 'q' deve continuar 0xA5 até o próximo clk

    @(posedge clk);
    #1; // Agora 'q' atualiza para 0x3C

    // ----------------------------------------------------
    // 4. Teste de Reset Síncrono Durante Operação
    // ----------------------------------------------------
    @(negedge clk);
    rst = 1;      // Ativa o reset mantendo d = 0x3C

    @(posedge clk);
    #1; // q deve voltar a 0x00 na borda do clock

    // Finaliza a simulação
    #10;
    $display("--- Simulação Concluída com Sucesso ---");
    $finish;
  end

endmodule