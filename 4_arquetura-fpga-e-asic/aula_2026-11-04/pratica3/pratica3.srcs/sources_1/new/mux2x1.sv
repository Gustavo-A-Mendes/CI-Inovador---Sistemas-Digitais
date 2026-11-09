`timescale 1ns/1ps

module mux2x1 (
    input logic [7:0] a,
    input logic [7:0] b,
    input logic sel,
    output logic [7:0] q
  );

  assign q = (sel == 1'b0) ? a : b;
endmodule