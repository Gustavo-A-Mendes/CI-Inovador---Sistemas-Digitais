module reg16 (
  input   logic clk, rst, en,
  input   logic [15:0] d,
  output  logic [15:0] q
);

  always @(posedge clk) begin
    if (rst)      q <= 16'b0;
    else if (en)  q <= d;
    // else omitido, represente retenção de estado (q <= q)
  end
  
endmodule