module mux8_4 (
  input   logic [7:0] a, b, c, d,
  input   logic [1:0] sel,
  output  logic [7:0] y
);

  always @(*) begin
    case (sel)
      2'b00:    y = a;
      2'b01:    y = b;
      2'b10:    y = c;
      2'b11:    y = d;
      default:  y = 8'hxx;
    endcase
  end

  // assign y = (sel == 2'b00) ? a 
  //          : (sel == 2'b01) ? b
  //          : (sel == 2'b10) ? c
  //          : (sel == 2'b11) ? d : 8'hxx;

endmodule