`timescale 1ns/1ps

module tb_up_counter;
  parameter N = 100;

  logic clk, rst;
  logic [7:0] count;

  up_counter uc0(.*);
  
  initial begin
    // initialize variables:
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 0;

    // Generate dumpfile:
    $dumpfile("result.vcd");
    $dumpvars(0, tb_up_counter);

    // Monitoring:
    $monitor("%tns \tclk = %b \trst = %b \tcounter = %d", $realtime, clk, rst, count);
    #2;
    rst = 1;

    @(posedge clk);

    #2;
    rst = 0;
    repeat(5) @(posedge clk); // Espera 5 ciclos de clock

    #2;
    rst = 1;

    repeat(2) @(posedge clk); // Espera 5 ciclos de clock

    rst = 0;

    repeat(6) @(posedge clk); // Espera 5 ciclos de clock

    $finish;
      

  end
endmodule