module reg8 (
  input   logic clk, rst, en, 
  input   logic [7:0] d,
  output  logic [7:0] q
);

  always_ff @( posedge clk, posedge rst ) begin
    if (rst)      q <= 8'd0;
    else if (en)  q <= d;
  end
endmodule