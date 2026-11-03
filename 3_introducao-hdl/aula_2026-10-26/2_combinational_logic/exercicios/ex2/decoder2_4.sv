module decoder2_4 (
  input   logic en,
  input   logic [1:0] sel,
  output  logic [3:0] y
);
  
  logic [3:0] decoded;

  always @(*) begin
    case (sel)
      2'b00:    decoded = 4'b0001;
      2'b01:    decoded = 4'b0010;
      2'b10:    decoded = 4'b0100;
      2'b11:    decoded = 4'b1000;
      default:  decoded = 4'b0000;
    endcase

    if (en) y = decoded;
    else    y = 4'b0000;
    
  end
endmodule