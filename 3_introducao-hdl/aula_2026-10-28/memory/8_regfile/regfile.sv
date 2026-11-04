module regfile (
  input   logic clk, we,
  input   logic [4:0] ra1, ra2,   // Endereços de leitura
  input   logic [4:0] wa,         // Endereço de escrita
  input   logic [31:0] wd,        // Dado de escrita
  output  logic [31:0] rd1, rd2   // Dado de leitura
);
  
  // Banco de 32 registradores de 32 bits:
  logic [31:0] regs [0:31];

  // Escrita síncrona na borda de subida do clock:
  always_ff @( posedge clk ) begin
    if (we && (wa != 5'd0))   regs[wa] <= wd;
  end

  // Duas postas de leitura assíncrona
  // O registrador $0 sempre retorna zero:
  assign rd1 = (ra1 == 5'd0) ? 32'd0 : regs[ra1];
  assign rd2 = (ra2 == 5'd0) ? 32'd0 : regs[ra2];
endmodule