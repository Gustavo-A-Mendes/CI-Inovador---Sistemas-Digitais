`timescale 1ns/1ps

module shift_register8_tb;

  // Sinais para conectar ao DUT (Device Under Test)
  logic       clk;
  logic       rst_n;
  logic       en;
  logic       dir;
  logic       serial_in;
  logic       parallel_en;
  logic [7:0] d;
  logic [7:0] q;

  // Instância do módulo DUT
  shift_register8 dut (
      .clk        (clk),
      .rst_n      (rst_n),
      .en         (en),
      .dir        (dir),
      .serial_in  (serial_in),
      .parallel_en(parallel_en),
      .d          (d),
      .q          (q)
  );

  // Geração do Clock (período de 10ns = 100MHz)
  always #5 clk = ~clk;

  // Sequência de Testes
  initial begin
    // Dump de formas de onda para VCD (gtkwave / EDA Playground)
    $dumpfile("shift_register8.vcd");
    $dumpvars(0, shift_register8_tb);

    // Initializations
    clk         = 0;
    rst_n       = 0;
    en          = 0;
    dir         = 0;
    serial_in   = 0;
    parallel_en = 0;
    d           = 8'h00;

    // ----------------------------------------------------
    // 1. Teste de Reset Assíncrono
    // ----------------------------------------------------
    #12 rst_n = 1; // Libera o reset fora da borda de subida do clock
    @(posedge clk);
    $display("[%0t] Reset liberado. q = %b (Esperado: 00000000)", $time, q);

    // ----------------------------------------------------
    // 2. Carga Paralela (parallel_en = 1)
    // ----------------------------------------------------
    @(posedge clk);
    d = 8'b1010_1100;
    parallel_en = 1;
    
    @(posedge clk);
    parallel_en = 0;
    #1; // Pequeno atraso para leitura estável
    $display("[%0t] Carga paralela: q = %b (Esperado: 10101100)", $time, q);

    // ----------------------------------------------------
    // 3. Deslocamento para a Direita (dir = 0)
    //    Insere 1, depois 0, mantendo dir = 0
    // ----------------------------------------------------
    @(posedge clk);
    en        = 1;
    dir       = 0; // Direita: {serial_in, q[7:1]}
    serial_in = 1;
    
    @(posedge clk);
    #1;
    $display("[%0t] Desloca Direita (in=1): q = %b (Esperado: 11010110)", $time, q);

    serial_in = 0;
    @(posedge clk);
    #1;
    $display("[%0t] Desloca Direita (in=0): q = %b (Esperado: 01101011)", $time, q);

    // ----------------------------------------------------
    // 4. Deslocamento para a Esquerda (dir = 1)
    // ----------------------------------------------------
    dir       = 1; // Esquerda: {q[6:0], serial_in}
    serial_in = 1;
    @(posedge clk);
    #1;
    $display("[%0t] Desloca Esquerda (in=1): q = %b (Esperado: 11010111)", $time, q);

    // ----------------------------------------------------
    // 5. Prioridade (en vs parallel_en)
    //    No seu código, se `en` e `parallel_en` forem 1, 
    //    o `en` tem prioridade sobre o `parallel_en`.
    // ----------------------------------------------------
    parallel_en = 1;
    d           = 8'b1111_0000;
    serial_in   = 0;
    dir         = 0; // Desloca a direita
    
    @(posedge clk);
    #1;
    $display("[%0t] Teste Prioridade (en=1, parallel_en=1): q = %b (Esperado: 01101011)", $time, q);

    // Desativa 'en' para verificar se 'parallel_en' carrega 'd'
    en = 0;
    @(posedge clk);
    #1;
    $display("[%0t] Carga Paralela com en=0: q = %b (Esperado: 11110000)", $time, q);

    // Finaliza a simulação
    #20;
    $display("--- Fim da Simulação ---");
    $finish;
  end

endmodule