`timescale 1ns/1ps
module ram_re #(
  parameter AW = 6,
            DW = 8
) (
  input   logic clk, we, re,
  input   logic [AW-1:0] addr,
  input   logic [DW-1:0] din,
  output  logic [DW-1:0] dout
);
  
  // Memória: 2^AW palavras de DW de bits:
  logic [DW-1:0] mem [0:(1<<AW)-1];

  /*
    Leitura e Escrita no mesmo ciclo:

    Modos comuns: read-first, write-first e no-change.
  */

  // Modo write-first:
  always_ff @( posedge clk ) begin
    if (we)   mem[addr] <= din;   // Escrita
    if (re)   dout <= mem[addr];  // Leitura
  end
endmodule