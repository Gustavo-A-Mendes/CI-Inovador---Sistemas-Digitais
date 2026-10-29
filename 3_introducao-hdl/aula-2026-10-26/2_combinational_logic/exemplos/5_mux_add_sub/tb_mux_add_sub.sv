`timescale 1ns/1ps

module tb_mux_add_sub;

  logic [7:0] a, b, y;
  logic [1:0] op;

  mux_add_sub m0(.*);

  initial begin
    $monitor("a = %d \tb = %d \top = %b \ty = %d", a, b, op, y);
  end
  
  initial begin

    a = 8'd25; b = 8'd7;
    op = 2'b00;
    #5;

    op = 2'b10;
    #5;

    op = 2'b01;
    #5;

    op = 2'b11;
    #5;

    op = 2'b01;
    #5;

    
    $finish(2);
  end

endmodule