`timescale 1ns/1ps

module tb_reg16;
  logic clk, rst, en;
  logic [15:0] d, q;

  // Instanciação do registrador:
  reg16 r0(.*);

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $monitor("%tns \tclk = %b \trst = %b \ten = %b \td = %d \tq = %d", $time, clk, rst, en, d, q);

    #2 rst = 1; en = 0;

    repeat(2) @(posedge clk); // Aguarda 2 ciclos de clock;

    #2 rst = 0;

    repeat(1) @(posedge clk); // Aguarda 1 ciclos de clock;
    
    d = 16'b0110_1000_0101_1111;
    #2 en = 1;

    repeat(2) @(posedge clk); // Aguarda 2 ciclos de clock;

    $finish;
  end

endmodule