`timescale 1ns/1ps

module tb_decoder2_4;

  logic en;
  logic [1:0] sel;
  logic [3:0] y;

  decoder2_4 d0(.*);

  initial begin
    $dumpfile("tb_decoder.vcd");
    $dumpvars;

    $monitor("%tns \ten = %bsel = %b \ty = %b",$time, en, sel, y);
  end

  initial begin
    en = 1'b0; // teste com enable desativado

    sel = 2'b00; #5;
    sel = 2'b01; #5;
    sel = 2'b10; #5;
    sel = 2'b11; #5;

    en = 1'b1;  // teste com enable ativado

    sel = 2'b00; #5;
    sel = 2'b01; #5;
    sel = 2'b10; #5;
    sel = 2'b11; #5;

    $finish;
  end 

endmodule