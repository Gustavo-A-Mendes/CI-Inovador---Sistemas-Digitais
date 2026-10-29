`timescale 1ns/1ps

module add8_tb;

  reg [7:0] a, b, sum;
  reg cin, cout;

  add8 add0(
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
  );

  initial begin
    $dumpfile("add8_tb.vcd");
    $dumpvars(0, add8_tb);
  end

  initial begin
    #2;
    a = 8'd0; b = 8'd0; cin = 1'b0;
    #10;

    a = 8'd3; b = 8'd5; cin = 1'b1;
    #10;

    a = -8'd20; b = 8'd40; cin = 1'b0;
    #10;
    
    a = 8'd250; b = 8'd30; cin = 1'b0;
    #10;

    $finish;
  end

endmodule