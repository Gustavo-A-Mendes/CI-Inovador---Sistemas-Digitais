`timescale 1ns/1ps

module tb_n_counter;
  parameter MAX_SIZE = 8;
  parameter N = 80;

  logic clk, rst, en;
  logic [MAX_SIZE-1:0] count;

  n_counter #(.MAX_SIZE(MAX_SIZE), .N(N)) enuc0(.*);
  
  initial begin
    // initialize variables:
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 0; en = 0;

    // Generate dumpfile:
    $dumpfile("n_counter.vcd");
    $dumpvars(0, tb_n_counter);

    // Monitoring:
    $monitor("%tns \tclk = %b \trst = %b \ten = %b \tcounter = %d", $realtime, clk, rst, en, count);
    #2;
    rst = 1;

    @(posedge clk);

    #2;
    rst = 0;
    repeat(1) @(posedge clk); // Espera 1 ciclos de clock
    
    en = 1;
    repeat(102) @(posedge clk); // Espera 5 ciclos de clock

    $finish;
      

  end
endmodule