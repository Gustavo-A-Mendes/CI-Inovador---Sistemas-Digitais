module mux2_proc (
  input  wire [7:0] a, b,
  input  wire       sel,
  output reg  [7:0] y
);

  always @(*) begin
    if (sel == 1'b0) y = a;
    else             y = b;
  end

endmodule