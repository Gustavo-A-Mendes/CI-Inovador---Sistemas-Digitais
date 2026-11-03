module regbank (
  input   logic clk, rst,
  input   logic [3:0] en,
  input   logic [31:0] d,
  output  logic [31:0] q
);

  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : g
      reg8 rg(
        .*,
        .en(en[i]),
        .d(d[8*i +: 8]),
        .q(q[8*i +: 8])
      );
    end
  endgenerate
endmodule