module ram_256x8 (
  input   logic clk, we,
  input   logic [7:0] addr,
  input   logic [7:0] data_in,
  output  logic [7:0] data_out
);
  
  // 256 posições de 8bits:
  logic [7:0] mem [0:255];

  // Inicialização da memória:
  initial begin
    for (int i = 0; i < 256; i++) begin
      mem[i] = 8'h00;
    end

    // Add valores inicias:
    mem[0] = 8'h12;
    mem[1] = 8'h34;
    mem[2] = 8'h56;
    mem[3] = 8'h78;
    mem[4] = 8'hAB;
    mem[5] = 8'hCD;
    // inicializar também os demais endereços...
  end

  always_ff @( posedge clk ) begin
    if (we)   mem[addr] <= data_in;
    else      data_out <= mem[addr];
  end
endmodule