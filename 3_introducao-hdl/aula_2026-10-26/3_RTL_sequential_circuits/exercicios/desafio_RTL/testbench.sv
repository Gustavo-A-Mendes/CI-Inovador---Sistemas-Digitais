`timescale 1ns / 1ps

module tb_top_level;

  // Sinais para conectar na UUT (Unit Under Test)
  logic clk;
  logic reset;
  logic up_down;
  logic lr;
  logic sel;
  logic [7:0] data_in;
  logic [6:0] display [1:0];

  // Instância da UUT
  top_level uut (
    .clk(clk),
    .reset(reset),
    .up_down(up_down),
    .lr(lr),
    .sel(sel),
    .data_in(data_in),
    .display(display)
  );

  // Geração do Sinal de Clok (Período = 10ns -> 100MHz)
  always #5 clk = ~clk;

  // Estímulos
  initial begin
    // Inicialização dos Sinais
    clk = 0;
    reset = 1;
    up_down = 1;
    lr = 0;
    sel = 0;
    data_in = 8'd0;

    // Configuração para geração de arquivo de formas de onda (GTKWave/Icarus)
    $dumpfile("tb_top_level.vcd");
    $dumpvars(0, tb_top_level);

    // Exibição dos resultados no terminal
    $monitor("Tempo=%0t ns | Reset=%b | Count_Dir=%s | Sel=%s | Data_In=0x%h | Disp1=7'b%b | Disp0=7'b%b",
             $time, reset, (up_down ? "UP" : "DOWN"), (sel ? "SUB" : "ADD"), data_in, display[1], display[0]);

    // 1. Aplicação do Reset
    #20;
    reset = 0;
    #10;

    // 2. Carrega um valor no registrador de entrada (data_in = 0x05)
    data_in = 8'h05;
    lr = 1;
    #10;
    lr = 0; // Desativa o sinal de carga

    // 3. Deixa o contador incrementar (Up) e testar a SOMA (sel = 0)
    // O pipeline do pipeline de registradores leva ~2 ciclos de clock para atualizar a saída do display
    #50;

    // 4. Muda a operação para SUBTRAÇÃO (sel = 1)
    sel = 1;
    #40;

    // 5. Altera a direção do contador para DECREMENTO (down_down = 0)
    up_down = 0;
    #40;

    // 6. Carrega um novo valor no registrador (data_in = 0x0F)
    data_in = 8'h0F;
    lr = 1;
    #10;
    lr = 0;

    #50;

    // Finaliza a simulação
    $display("Simulação concluída com sucesso.");
    $finish;
  end

endmodule