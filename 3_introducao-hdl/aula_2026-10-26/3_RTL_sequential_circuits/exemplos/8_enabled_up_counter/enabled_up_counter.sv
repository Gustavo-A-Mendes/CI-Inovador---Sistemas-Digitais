module enabled_up_counter(
  input logic clk, rst, en,
  output reg [7:0] count
);

  always @(posedge clk, posedge rst) begin
    if (rst)      count <= 8'd0;
    else if (en)  count <= count + 8'd1;
  end
endmodule