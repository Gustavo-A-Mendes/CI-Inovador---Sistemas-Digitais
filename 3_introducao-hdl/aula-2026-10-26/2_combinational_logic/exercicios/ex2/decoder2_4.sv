module decoder2_4 (
  input   logic en,
  input   logic [1:0] sel,
  output  logic [3:0] y
);
  
  always @(*) begin
    if (en == 1'b0) y = 4'b0000;
    else begin
      case (sel)
        2'b00:    y = 4'b0001;
        2'b01:    y = 4'b0010;
        2'b10:    y = 4'b0100;
        2'b11:    y = 4'b1000;
        default:  y = 4'b0000;
      endcase
    end
  end
endmodule