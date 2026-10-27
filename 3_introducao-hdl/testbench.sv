`timescale 1ns/1ps  // 1,00 ns, 2,00 ns, 3,00 ns

module testbench;
  parameter N = 32;
  
  wire clk, [N-1:0] a, [N-1: 0] b, [N-1:0] y;

  and_N_gate #(.N(1)) a0(.clk(clk), .a(a), .b(b), .y(y));

  always begin
    clk = ~clk; #2; // #4 - 4ns
  end

  initial begin

    $dumpfile("teste.vcd");
    $dumpvars;

    clk = 1'd0;
    // forever clk = ~clk; #2;

    a = 0; b = 0;
    #5;
    
    a = 0; b = 1; // #0
    #6;
    
    a = 1; b = 0;
    #10;

    a = 1; b = 0; 
    #10;

    $display("Ola mundo");

    $monitor("time = %tns \t a = %b, b = %b, y = %b", $time, clk, a, b, y);
    // time = 0.000ns, a = 0, b = 0, y = 0
    // time = 5.000ns, a = 0, b = 1, y = 0


    $finish;
  end

  
endmodule