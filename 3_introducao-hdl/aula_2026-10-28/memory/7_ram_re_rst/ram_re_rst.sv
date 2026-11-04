`timescale 1ns/1ps
module ram_re_rst (
  input   logic clk, rst, we, re,
  input   logic [7:0] addr,
  input   logic [7:0] din,
  output  logic [7:0] dout
);
  
  // BRAM (Block RAM):
  logic [7:0] mem [0:255];

  /*
    Não resetamos a BRAM.
    O reset é aplicado em sinais de controle e registradores de saída (dout)
  */

  always_ff @( posedge clk ) begin
    if (we)       mem[addr] <= din;   // Escrita
    
    // Reset de saída, não no array;
    if (rst)      dout <= 8'h00;
    else if (re)  dout <= mem[addr];  // Leitura
  end
endmodule