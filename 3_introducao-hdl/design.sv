module and_N_gate 
#(
  parameter N = 4;
)
(
  input wire clk, 
  input wire [N-1:0] a,
  input wire [N-1:0] b, 
  output wire [N-1:0] y
);

  always @(posedge clk) begin
    // a = 0101
    // b = 1110
    y = a & b; // y = 0100
  end

endmodule