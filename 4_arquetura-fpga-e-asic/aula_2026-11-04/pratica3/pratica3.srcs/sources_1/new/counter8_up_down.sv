`timescale 1ns/1ps

module counter8_up_down (
    input logic clk,
    input logic reset,
    input logic up_down,
    output logic [7:0] count
  );

  always @(posedge clk) begin
    if (reset)          count <= 8'b0;
    else if (up_down)   count <= count + 1'b1;
    else                count <= count - 1'b1;
  end
endmodule