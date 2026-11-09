`timescale 1ns / 1ps

module reg8_lr (
    input logic clk,
    input logic reset,
    input logic lr,
    input logic [7:0] d,
    output logic [7:0] q
  );

  always @(posedge clk) begin
    if (reset)          q <= 8'b0;
    else if (lr)        q <= d;
    else                q <= q; // Implícito, não é obrigatório
  end
endmodule
