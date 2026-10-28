module moduleName (
  input clk,
  input rst,
  input in_A,
  output reg out_D
);
  
  localparam [2:0]  S0 = 3'b000,
                    S1 = 3'b001,
                    S2 = 3'b010,
                    S3 = 3'b011,
                    S4 = 3'b100;

  reg [2:0] state, next_state;

  always @(posedge clk) begin
    if (rst)    state <= S0;
    else        state <= next_state;
  end

  always @(*) begin
    // next_state = state; 
    out_D = 1'b0;

    case(state)
      S0: begin
        out_D = 1'b0;

        if (in_A)   next_state = S1;
        else        next_state = S0;
      end

      S1: begin
        out_D = 1'b0;
        
        if (in_A)   next_state = S2;
        else        next_state = S0;
      end

      S2: begin
        out_D = 1'b0;
        
        if (in_A)   next_state = S2;
        else        next_state = S3;
      end

      S3: begin
        out_D = 1'b0;
        
        if (in_A)   next_state = S4;
        else        next_state = S0;
      end

      S4: begin
        out_D = 1'b1;
        
        if (in_A)   next_state = S1;
        else        next_state = S0;
      end

      default: begin
        out_D = 1'b0;
        next_state = S0;
      end
    endcase
  end

endmodule

