`timescale 1ns / 1ps

module testbench;
  
  parameter N = 4;
  
  logic a, b;
  logic s;
  
  logic [0:1] memory [0:N-1];
  integer i;
  
  and2 a0(.a(a), .b(b), .y(s));
  
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