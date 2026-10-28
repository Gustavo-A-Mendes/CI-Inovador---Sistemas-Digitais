`timescale 1ns/1ps

module reg8_tb;

  // Sinais de teste
  logic       clk;
  logic       rst;
  logic       en;
  logic [7:0] d;
  logic [7:0] q;

  // Instância do DUT
  reg8 dut (
      .clk(clk),
      .rst(rst),
      .en (en),
      .d  (d),
      .q  (q)
  );

  // Geração do Clock (período de 10ns = 100MHz)
  always #5 clk = ~clk;

  // Sequência de Testes
  initial begin
    // Configura a formatação do %0t para exibir em ns sem casas decimais
    $timeformat(-9, 0, " ns", 10);

    // Arquivo de ondas para visualização (GTKWave / EDA Playground)
    $dumpfile("reg8.vcd");
    $dumpvars(0, reg8_tb);

    // Inicialização dos sinais
    clk = 0;
    rst = 1;      // Começa em Reset
    en  = 0;
    d   = 8'h00;

    // Monitoramento contínuo das alterações usando %0t
    $monitor("[%0t] clk = %b | rst = %b | en = %b | d = 0x%h (%b) | q = 0x%h (%b)", 
             $time, clk, rst, en, d, d, q, q);

    // ----------------------------------------------------
    // 1. Teste do Reset Inicial (rst=1, en=0)
    // ----------------------------------------------------
    #2 d = 8'hFF;
    
    @(posedge clk);
    #1; // q deve permanecer em 0x00 devido ao rst=1

    // ----------------------------------------------------
    // 2. Tenta Escrever sem Enable (rst=0, en=0)
    // ----------------------------------------------------
    @(negedge clk);
    rst = 0;
    d   = 8'hAA; // 10101010

    @(posedge clk);
    #1; // q deve continuar 0x00 pois en=0

    // ----------------------------------------------------
    // 3. Escrita Normal (rst=0, en=1)
    // ----------------------------------------------------
    @(negedge clk);
    en = 1;

    @(posedge clk);
    #1; // q deve ser atualizado para 0xAA

    // ----------------------------------------------------
    // 4. Retenção de Dado (rst=0, en=0)
    // ----------------------------------------------------
    @(negedge clk);
    en = 0;
    d  = 8'h55; // Altera entrada, mas não deve gravar

    @(posedge clk);
    #1; // q deve manter 0xAA

    // ----------------------------------------------------
    // 5. Prioridade do Reset (rst=1, en=1)
    //    Como rst vem primeiro no 'if', ele deve zerar 'q'
    //    mesmo com en=1 e d com valor válido.
    // ----------------------------------------------------
    @(negedge clk);
    rst = 1;
    en  = 1;
    d   = 8'hFF;

    @(posedge clk);
    #1; // q deve ir para 0x00 (comprovando prioridade do rst)

    // Finaliza a simulação
    #10;
    $display("--- Simulação Concluída com Sucesso ---");
    $finish;
  end

endmodule