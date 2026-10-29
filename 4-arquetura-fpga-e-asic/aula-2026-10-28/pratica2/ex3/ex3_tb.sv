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
    $display("                Tempo      Entradas LUT      Saídas");
    $display("                \t\t A\t B\t Cin\t\t XOR0\t AND0\t AND1\t AND2\tCout  S");
    $display("                ====   ===============    ==============================================");
    $monitor($time,"\t %b\t %b\t  %b\t\t\t  %b\t\t  %b\t\t  %b\t\t  %b\t\t %b\t  %b", A, B, Cin, lut0.O_XOR0, lut0.O_AND0, lut0.O_AND1, lut0.O_AND2, Cout, S);      
  end
  
endmodule
