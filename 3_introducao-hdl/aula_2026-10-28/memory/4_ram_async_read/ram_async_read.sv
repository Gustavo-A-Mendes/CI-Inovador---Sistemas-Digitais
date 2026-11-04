`timescale 1ns/1ps
module ram_async_read #(
  parameter AW = 8,
            DW = 8
) (
  input   logic clk, we,
  input   logic [AW-1:0] addr,
  input   logic [DW-1:0] din,
  output  logic [DW-1:0] dout
);
  
  logic [DW-1:0] mem [0:(1<<AW)-1];

  // Escrita síncrona:
  always_ff @( posedge clk ) begin
    if (we)   mem[addr] <= din;
  end

  // Leitura assíncrona:
  assign dout = mem[addr];
endmodule