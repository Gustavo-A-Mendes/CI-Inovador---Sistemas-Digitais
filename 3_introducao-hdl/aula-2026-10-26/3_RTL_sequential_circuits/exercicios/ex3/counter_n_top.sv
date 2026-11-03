module counter_n_top (
  input   logic clk, rst, en,
  output  logic [3:0] count10, count16
);

  // Contador até 10:
  counter_n #(.W(4), .N(10)) cn0(.*, .count(count10));

  // Contador até 16:
  counter_n #(.W(4), .N(16)) cn1(.*, .count(count16));

endmodule