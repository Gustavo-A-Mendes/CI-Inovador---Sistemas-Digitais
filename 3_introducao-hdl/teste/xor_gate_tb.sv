`timescale 1ns / 1ps

`include "xor_gate.sv"

module testbench;
  
  parameter N = 4;
  
  logic a, b;
  logic s;
  
  logic [0:1] memory [0:N-1];
  integer i;
  
  xor_gate x0(.a(a), .b(b), .s(s));
  
  initial begin
    $dumpfile("teste.vcd");
    $dumpvars(1, testbench);
    
    $readmemb("values.txt", memory);
    
    for (i = 0; i < N; i++) begin
      a = memory[i][0]; b = memory[i][1]; #2;
    end
    
    $finish;
  end
  
  initial begin
    $monitor("Tempo = %0f | a = %b \t b = %b \t s = %b", $realtime, a, b, s);
    
  end
  
endmodule