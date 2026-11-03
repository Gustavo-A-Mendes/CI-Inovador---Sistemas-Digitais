`timescale 1ns/1ps

module reg8_tb;

  // Sinais de teste
  logic       clk;
  logic       en;
  logic [7:0] d;
  logic [7:0] q;

  // Instância do DUT (Device Under Test)
  reg8 dut (
      .clk(clk),
      .en (en),
      .d  (d),
      .q  (q)
  );

  // Geração do Clock (período de 10ns = 100MHz)
  always #5 clk = ~clk;

  // Sequência de Testes
  initial begin
    // Arquivo de ondas para visualização (GTKWave / EDA Playground)
    $dumpfile("reg8.vcd");
    $dumpvars(0, reg8_tb);

    // Inicialização
    clk = 0;
    en  = 0;
    d   = 8'h00;

    // Monitoramento automático no terminal
    $monitor("[%0t] clk = %b | en = %b | d = 0x%h (%b) | q = 0x%h (%b)", 
             $time, clk, en, d, d, q, q);

    // ----------------------------------------------------
    // 1. Tenta escrever com Enable Desativado (en = 0)
    // ----------------------------------------------------
    #2 d = 8'hAA; // Apply 10101010
    
    @(posedge clk);
    #1; // q DEVE continuar mantendo seu valor anterior (x/indefinido ou 0)

    // ----------------------------------------------------
    // 2. Escrita com Enable Ativado (en = 1)
    // ----------------------------------------------------
    @(negedge clk);
    en = 1;

    @(posedge clk);
    #1; // q deve atualizar para 0xAA

    // ----------------------------------------------------
    // 3. Trava de Dados (en = 0): Muda 'd' mas mantém 'q'
    // ----------------------------------------------------
    @(negedge clk);
    en = 0;
    d  = 8'hFF; // Altera entrada para 11111111

    @(posedge clk);
    #1; // q DEVE permanecer em 0xAA pois en = 0

    // ----------------------------------------------------
    // 4. Nova Escrita (en = 1)
    // ----------------------------------------------------
    @(negedge clk);
    en = 1;

    @(posedge clk);
    #1; // q atualiza para 0xFF

    // Desativa enable e finaliza a simulação
    en = 0;
    #10;
    $display("--- Simulação Concluída com Sucesso ---");
    $finish;
  end

endmodule