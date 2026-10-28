module mux_n #(
  parameter N = 8
) (
  input wire 	[N-1:0]	d1, d2, d3, d4,
  input wire 	[1:0]	sel,
  output reg 	[N-1:0] y
);
  
  always @(*) begin
    case (sel)
      2'b00:	y = d1;
      2'b01:	y = d2;
      2'b10:	y = d3;
      2'b11:	y = d4;
    endcase
  end
endmodule