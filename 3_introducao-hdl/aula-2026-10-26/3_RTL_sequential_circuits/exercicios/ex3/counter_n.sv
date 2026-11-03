module counter_n #(
  parameter W = 4,
            N = 10
) (
  input   logic clk, rst, en,
  output  logic [W-1:0] count
);
  
  always_ff @(posedge clk) begin
    if (rst)            count <= 0;
    else if (en) begin
      if (count == N-1) count <= 0;
      else              count <= count + 1'b1;
    end
  end
endmodule