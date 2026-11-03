module ALU (
  input   logic [7:0] A, B,
  input   logic [2:0] opcode,
  output  logic [7:0] result,
  output  logic carry, zero
);
  
  always @(*) begin
    result = 8'bx; carry = 1'b0; zero = 1'b0;

    case (opcode)
      3'b000:   {carry, result} = {1'b0, A} + {1'b0, B}; 
      3'b001:   {carry, result} = {1'b0, A} - {1'b0, B}; 
      3'b010:   result = A & B;
      3'b011:   result = A | B;
      3'b100:   result = A ^ B;
      3'b101:   result = ~A;
      3'b110:   {carry, result} = {1'b0, A} << 1;
      3'b111:   result = A;
    endcase

    zero = (result == 1'b0);
  end

endmodule