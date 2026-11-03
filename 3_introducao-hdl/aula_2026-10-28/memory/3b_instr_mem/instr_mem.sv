module instr_mem (
  input   logic [5:0] addr,
  output  logic [7:0] instr
);
  
  logic [7:0] mem [0:3];
  
  // Inicialização usando initial e $readmemh:
  initial $readmemb("dados.bin", mem);

  assign instr = mem[addr];
endmodule