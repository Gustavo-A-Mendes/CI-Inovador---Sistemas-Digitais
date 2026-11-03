`timescale 1ns/1ps

module tb_up_down_counter;
  parameter N = 100;

  logic clk, rst;
  logic [1:0] sel;
  logic [7:0] d, q;

  up_down_counter udc0(.*);
  
  initial begin
    // initialize variables:
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 0;

    // Generate dumpfile:
    $dumpfile("up_down_counter.vcd");
    $dumpvars(0, tb_up_down_counter);

    // Monitoring:
    $monitor("%tns \tclk = %b \trst = %b \td = %b \tsel = %b \tcounter = %d", $realtime, clk, rst, d, sel, q);

    #2;
    rst = 1; d = 8'b1000_0010;

    @(posedge clk);

    #2;
    rst = 0; sel = 2'b00;
    repeat(2) @(posedge clk); // Espera 1 ciclos de clock
    #2;
    sel = 2'b01;
    repeat(5) @(posedge clk); // Espera 5 ciclos de clock

    sel = 2'b10;
    repeat(3) @(posedge clk); // Espera 3 ciclos de clock

    sel = 2'b11;
    repeat(5) @(posedge clk); // Espera 5 ciclos de clock

    #2;
    rst = 1;

    repeat(2) @(posedge clk); // Espera 5 ciclos de clock

    rst = 0; sel = 2'b10;

    repeat(6) @(posedge clk); // Espera 5 ciclos de clock

    $finish;
      

  end
endmodule