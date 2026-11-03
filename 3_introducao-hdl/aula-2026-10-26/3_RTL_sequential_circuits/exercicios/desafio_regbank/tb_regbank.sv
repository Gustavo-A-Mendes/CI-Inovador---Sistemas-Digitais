`timescale 1ns/1ps

module regbank_tb;

  // Sinais do Testbench
  logic        clk;
  logic        rst;
  logic [3:0]  en;
  logic [31:0] d;
  logic [31:0] q;

  // Instância do Banco de Registradores
  regbank dut (
    .clk (clk),
    .rst (rst),
    .en  (en),
    .d   (d),
    .q   (q)
  );

  // Geração do Clock (Período = 10ns)
  always #5 clk = ~clk;

  // Estímulos de Teste
  initial begin
    // Inicialização
    clk = 0;
    rst = 0;
    en  = 4'b0000;
    d   = 32'h0;

    // 1. Aplica Reset
    #2;
    rst = 1;
    #10;
    rst = 0;
    #10;

    // 2. Escreve apenas no BYTE 0 (en = 0001)
    d  = 32'h12_34_56_78;
    #1 en = 4'b0001;
    @(posedge clk);

    // 3. Escreve apenas no BYTE 1 (en = 0010)
    #2 en = 4'b0010;
    @(posedge clk);

    // 4. Escreve apenas nos BYTES 2 e 3 simultaneamente (en = 1100)
    #2 en = 4'b1100;
    @(posedge clk);

    // 5. Desabilita todos os 'en' e altera os dados de entrada 'd'
    // (Verifica se a saída 'q' mantém os valores armazenados)
    d  = 32'hFFFF_FFFF;
    #2 en = 4'b0000;
    repeat (3) @(posedge clk);

    // 6. Escreve em TODOS os bytes de uma vez (en = 1111)
    d  = 32'hDEAD_BEEF;
    #2 en = 4'b1111;
    @(posedge clk);

    // 7. Desabilita 'en' novamente
    #2 en = 4'b0000;
    @(posedge clk);

    // 8. Testa Reset assíncrono/síncrono com dados gravados
    rst = 1;
    @(posedge clk);
    rst = 0;
    @(posedge clk);

    $display("Simulação finalizada com sucesso!");
    $finish;
  end

  // Monitoramento no Terminal
  initial begin
    $monitor("Tempo: %0t | rst: %b | en: %b | d: 0x%h | q: 0x%h", 
             $time, rst, en, d, q);
  end

  // Gera arquivo de ondas VCD
  initial begin
    $dumpfile("regbank_tb.vcd");
    $dumpvars(0, regbank_tb);
  end

endmodule