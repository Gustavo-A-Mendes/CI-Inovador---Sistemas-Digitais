`timescale 1ns/1ps

module mux2_tb;

reg [7:0] a, b; 
reg sel;
wire [7:0] y;

mux2_proc m0(
  .a(a),
  .b(b),
  .sel(sel),
  .y(y)
);

initial begin
    $dumpfile("mux2_tb.vcd");
    $dumpvars(0, mux2_tb);
  end

  initial begin
    #2;

    a = 8'd3; b = 8'd5; sel = 1'b1;
    #10;

    a = -8'd20; b = 8'd40; sel = 1'b0;
    #10;

    $finish;
  end

endmodule