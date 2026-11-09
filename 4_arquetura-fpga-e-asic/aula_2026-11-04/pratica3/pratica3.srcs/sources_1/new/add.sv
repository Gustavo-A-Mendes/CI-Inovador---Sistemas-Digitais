`timescale 1ns/1ps

module add (
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] q
  );

  assign q = a + b;
endmodule