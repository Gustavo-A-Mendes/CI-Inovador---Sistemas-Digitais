module regN #(
  parameter N = 8
) (
  input   logic clk, rst,
  input   logic [N-1:0] d,
  output  logic [N-1:0] q
);

  always @(posedge clk, posedge rst) begin
    if (rst)  q <= 0;
    else      q <= d;
  end

endmodule