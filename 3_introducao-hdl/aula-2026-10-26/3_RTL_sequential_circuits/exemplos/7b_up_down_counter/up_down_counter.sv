module up_down_counter (
    input   logic clk, rst,
    input   logic [1:0] sel,
    input   logic [7:0] d,
    output  logic [7:0] q
);

    always @(posedge clk) begin
        if (rst) q = 0;
        else
          case(sel)
            2'b00: q <= d;      //carga paralela
            2'b01: q <= q + 1;  //up
            2'b10: q <= q - 1;  //down
            2'b11: q <= q; 
          endcase

    end
endmodule