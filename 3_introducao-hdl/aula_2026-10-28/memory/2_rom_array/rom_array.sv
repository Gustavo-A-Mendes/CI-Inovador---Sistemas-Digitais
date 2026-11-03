module rom_array (
  input   logic [3:0] addr,
  output  logic [7:0] data
);

  logic [7:0] rom [0:15];

  initial begin
    rom[0] = 8'h13;
    rom[1] = 8'hA2;
    rom[2] = 8'h5F;
    // inicializar também os demais endereços...
  end

  assign data = rom[addr];
endmodule