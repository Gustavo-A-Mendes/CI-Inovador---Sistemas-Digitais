module tb_reg_generate;
  parameter N = 8;

  logic clk, rst;
  logic [(4*N)-1:0] d, q;

  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : g
      regN #(.N(N)) u_rg(
        .clk(clk),
        .rst(rst),
        .d(d[i*8 +: 8]),
        .q(q[i*8 +: 8])
      );
    end
  endgenerate

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    
    $dumpfile("reg_generate.vcd");
    $dumpvars(0, tb_reg_generate);

    // $monitor("%tns \tclk = %b \trst = %b \t")

    rst = 1;
    #2;

    rst = 0;

    @(posedge clk);

    d = 0110_0010_1001_1011_1110_0011_1011_0100;
    
    repeat(3) @(posedge clk);

    $finish;
  end
endmodule