`timescale 1ns/1ps

module reg8_tb;

  // Sinais de entrada e saída
  logic       clk;
  logic [7:0] d;
  logic [7:0] q;

  // Instância do DUT (Device Under Test)
  reg8 dut (
      .clk(clk),
      .d  (d),
      .q  (q)
  );

  // Geração do Clock (período de 10ns = 100MHz)
  always #5 clk = ~clk;

  // Estímulos de teste
  initial begin
    // Arquivo de gravação das ondas para visualização (GTKWave / EDA Playground)
    $dumpfile("reg8.vcd");
    $dumpvars(0, reg8_tb);

    // Inicialização
    clk = 0;
    d   = 8'h00;

    // Monitoramento automático no terminal
    $monitor("[%0t] clk = %b | Entrada d = 0x%h (%b) | Saída q = 0x%h (%b)", 
             $time, clk, d, d, q, q);

    // Teste 1: Aplica valor no tempo t=0 (antes da primeira borda)
    #2 d = 8'hAA; // 10101010

    // Aguarda a primeira borda de subida do clock
    @(posedge clk);
    // Teste 2: Altera 'd' entre bordas de clock (não deve mudar 'q' imediatamente)
    #4 d = 8'h55; // 01010101
    // Aqui 'q' ainda deve manter 0xAA até a próxima subida do clock

    @(posedge clk);

    // Teste 4: Testando outro valor
    @(negedge clk);
    d = 8'hFF; // 11111111

    // Fim do teste
    #10;
    $display("--- Simulação Concluída com Sucesso ---");
    $finish;
  end

endmodule