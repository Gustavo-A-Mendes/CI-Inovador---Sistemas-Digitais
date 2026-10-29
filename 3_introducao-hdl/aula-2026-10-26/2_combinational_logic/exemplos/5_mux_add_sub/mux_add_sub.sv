module mux_add_sub (
  input   logic [7:0] a, b,
  input   logic [1:0] op,
  output  logic [7:0] y
);
  
  always @(*) begin
    case (op)
      2'b00:    y = a + b;
      2'b01:    y = a - b;
      default:  y = 8'h00;
    endcase
  end
endmodule