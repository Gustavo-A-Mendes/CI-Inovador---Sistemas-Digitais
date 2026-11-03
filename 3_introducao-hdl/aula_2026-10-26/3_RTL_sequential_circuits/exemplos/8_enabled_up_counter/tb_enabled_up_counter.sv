`timescale 1ns/1ps

module tb_enabled_up_counter;
  parameter N = 100;

  logic clk, rst, en;
  logic [7:0] count;

  enabled_up_counter enuc0(.*);
  
  initial begin
    // initialize variables:
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 0; en = 0;

    // Generate dumpfile:
    $dumpfile("en_up_counter.vcd");
    $dumpvars(0, tb_enabled_up_counter);

    // Monitoring:
    $monitor("%tns \tclk = %b \trst = %b \ten = %b \tcounter = %d", $realtime, clk, rst, en, count);
    #2;
    rst = 1;

    @(posedge clk);

    #2;
    rst = 0;
    repeat(1) @(posedge clk); // Espera 1 ciclos de clock
    
    en = 1;
    repeat(5) @(posedge clk); // Espera 5 ciclos de clock

    en = 0;
    repeat(2) @(posedge clk); // Espera 2 ciclos de clock

    #2;
    rst = 1; en = 1;

    repeat(2) @(posedge clk); // Espera 2 ciclos de clock

    rst = 0;

    repeat(6) @(posedge clk); // Espera 6 ciclos de clock

    $finish;
      

  end
endmodule