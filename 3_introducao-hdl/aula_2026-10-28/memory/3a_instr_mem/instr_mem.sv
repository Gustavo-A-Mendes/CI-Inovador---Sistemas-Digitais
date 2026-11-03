module instr_mem (
  input   logic [5:0] addr,
  output  logic [31:0] instr
);
  
  logic [31:0] mem [0:63];
  
  // Inicialização usando initial e $readmemh:
  initial $readmemh("program.hex", mem);

  assign instr = mem[addr];
endmodule