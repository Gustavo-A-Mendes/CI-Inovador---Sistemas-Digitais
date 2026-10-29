`timescale  1ps/1ps

module LUT2_simplified_tb;
  logic A, B, C, D, O_simp;
  
  logic [0:3] memory [0:15];
  integer i;

  // Instância do circuito de LUT2:
  LUT2_circuit_simplified lut0(.*);
  
  initial
    begin
      $readmemb("input_values.txt", memory);

      for (i = 0; i < 16; i++) begin
        A = memory[i][0]; B = memory[i][1]; C = memory[i][2]; D = memory[i][3];
        #5;
      end
    end
  
    initial
    begin
      $display("                Tempo          Entradas LUT                   Saídas");
      $display("                   \t A\t B\t C\t D\t X0\t X1\t O  ");
      $display("                =====   ===========================    ======================");
      $monitor($time," \t %b\t %b\t %b\t %b \t %b\t %b\t %b", A, B, C, D, lut0.O_NAND0, lut0.O_AND0, O_simp);
    end
  
endmodule
