`timescale  1 ps / 1 ps
module LUT23_tb;
  
  logic A, B, Cin, S, Cout;
  
  logic [0:2] memory [0:7];
  integer i;
  
  LUT_circuit_ex3 lut0(.*);
  
  initial begin
    $readmemb("input_values.txt", memory);

    for (i = 0; i < 8; i++) begin
      A = memory[i][0]; B = memory[i][1]; Cin = memory[i][2];
      #5;
    end
    
    $finish;
  end
  
  initial begin
    $display("                Tempo        Entradas LUT               Saídas");
    $display("                \t A\t B\t Cin\t  X0 X1 X2 X3  Cout  S");
    $display("                =====   ======================   =======================");
    $monitor($time,"\t %b\t %b\t  %b\t  %b  %b  %b  %b    %b    %b", A, B, Cin, lut0.X0, lut0.X1, lut0.X2, lut0.X3, Cout, S);      
  end
  
endmodule
