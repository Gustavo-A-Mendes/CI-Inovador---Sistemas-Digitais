`timescale 1ns/1ps

module counter_10_tb;

  // Sinais do Testbench
  logic clk, rst, en;
  logic [3:0] count10, count16;

  // Instância do Módulo sob Teste (DUT)
  counter_n_top dut(.*);

  // Geração do Clock (Período = 10ns)
  always #5 clk = ~clk;

  // Estímulos de Teste
  initial begin
    // Inicialização das variáveis
    clk = 0;
    rst = 0;
    en  = 0;

    // 1. Aplica Reset Inicial
    #2;
    rst = 1;
    #10;
    rst = 0;
    #10;

    // 2. Habilita a contagem por 20 ciclos de clock
    // (Verifica o incremento continuo e o rollover de 9 para 0)
    en = 1;
    repeat (20) @(posedge clk);

    // 3. Desabilita o contador por 5 ciclos (Testa o sinal 'en')
    en = 0;
    repeat (5) @(posedge clk);

    // 4. Habilita novamente por mais 5 ciclos
    en = 1;
    repeat (5) @(posedge clk);

    // 5. Aplica Reset no meio da contagem
    rst = 1;
    @(posedge clk);
    rst = 0;
    repeat (3) @(posedge clk);

    // Finaliza a simulação após aproximadamente 35+ ciclos no total
    $display("Simulação finalizada com sucesso!");
    $finish;
  end

  // Monitoramento no Terminal (Console)
  initial begin
    $monitor("Tempo: %0t \t| clk: %b | rst: %b | en: %b | count10: %d | count10: %d", $time, clk, rst, en, count10, count16);
  end

  // Geração do arquivo VCD para visualização das formas de onda (GTKWave/EDA Playground)
  initial begin
    $dumpfile("counter_n_tb.vcd");
    $dumpvars(0, counter_10_tb);
  end

endmodule