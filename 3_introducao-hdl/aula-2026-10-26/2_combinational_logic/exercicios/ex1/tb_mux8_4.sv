`timescale 1ns/1ps

module tb_mux8_4;

  logic [7:0] a, b, c, d, y;
  logic [1:0] sel;

  mux8_4 m0(.*);

  initial begin
    $monitor("a = %d \tb = %d \tc = %d \td = %d \tsel = %b \ty = %d", a, b, c, d, sel, y);
  end

  initial begin
    a = 8'd10; b = 8'd20; c = 8'd30; d = 8'd40;
    sel = 2'b00;
    #5;

    sel = 2'b01;
    #5;

    sel = 2'b10;
    #5;

    sel = 2'b11;
    #5;

    $finish;
  end
endmodule