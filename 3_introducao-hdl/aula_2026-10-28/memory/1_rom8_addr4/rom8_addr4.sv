module rom_case (
  input   logic [1:0] addr,
  output  logic [7:0] data
);

  always @(*) begin
    case(addr)
      2'd0:     data = 8'h12;
      2'd1:     data = 8'hA5;
      2'd2:     data = 8'h3C;
      default:  data = 8'h00;
    endcase
  end

endmodule;