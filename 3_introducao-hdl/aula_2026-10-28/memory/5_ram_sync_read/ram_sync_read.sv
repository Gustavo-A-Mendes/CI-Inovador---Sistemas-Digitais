`timescale 1ns/1ps
module ram_sync_read #(
  parameter AW = 8,
            DW = 8
) (
  input   logic clk, we,
  input   logic [AW-1:0] addr,
  input   logic [DW-1:0] din,
  output  logic [DW-1:0] dout
);
  
  // Memória: 2^AW palavras de DW de bits:
  logic [DW-1:0] mem [0:(1<<AW)-1];

  // Escrita e Leitura síncrona:
  always_ff @( posedge clk ) begin
    if (we)   mem[addr] <= din;   // Escrita
    else      dout <= mem[addr];  // Leitura
  end
endmodule