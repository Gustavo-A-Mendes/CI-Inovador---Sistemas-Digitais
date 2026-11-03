module n_counter #(
  parameter MAX_SIZE = 8,
  parameter N = 100
) (
  input logic clk, rst, en,
  output reg [MAX_SIZE-1:0] count
);

  always @(posedge clk, posedge rst) begin
    if (rst)      count <= 0;
    else if (en) begin
      if (count == N-1) count <= 0;
      else              count <= count + 1'b1;
    end
  end
endmodule