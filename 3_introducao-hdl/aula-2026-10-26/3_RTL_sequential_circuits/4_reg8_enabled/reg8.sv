module reg8 (
  input wire clk,
  input wire en,
  input wire [7:0] d,
  output reg [7:0] q
);

  always @(posedge clk) begin
    if (en)   q <= d;
    else      q <= q;  // Declaração implícita, não é necessária
  end

endmodule