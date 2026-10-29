`timescale  1 ps / 1 ps
module LUT3_tb;

  logic A0, A1, A2, A3, O;

  logic [0:3] memory [0:15];
  integer i;
  
  LUT3_circuit_ex2 lut0(.*);
  
  initial
    begin
      $readmemb("input_values.txt", memory);

      for (i = 0; i < 16; i++) begin
        A3 = memory[i][0]; A2 = memory[i][1]; A1 = memory[i][2]; A0 = memory[i][3];
        #5;
      end

      $finish;
    end
  
  initial
    begin
      $display("                Tempo        Entradas LUT                    Saídas");
      $display("                         A3    A2    A1    A0       X0   X1   X2   X3   X4   O  ");
      $display("                ====   ========================   ================================");
      $monitor($time,"      %b     %b     %b     %b       %b    %b    %b    %b    %b    %b", lut0.A3, lut0.A2, lut0.A1, lut0.A0, lut0.X0, lut0.X1, lut0.X2, lut0.X3, lut0.X4, O);
    end
  
endmodule
