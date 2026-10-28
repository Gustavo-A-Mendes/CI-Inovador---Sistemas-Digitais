`timescale 1ns/1ps

module LUT2_tb;

  // Sinais de entrada
  logic A, B, C, D;

  // sinais do testbench com o circuito original:
  logic O_NAND0_ori, O_NAND1_ori, O_NAND2_ori, O_ori;

  // sinais do testbench com o circuito simplificado:
  logic O_NAND0_simp, O_AND0_simp, O_simp;

  // Memória para os vetores de teste (16 posições de 4 bits)
  logic [3:0] memory [0:15];

  // Variáveis de controle do teste
  int i;
  int error_count = 0;

  // Instâncias dos módulos sob teste (DUTs)
  LUT2_original_tb lutORI(.*);
  LUT2_simplified_tb lutSIMP(.*);

  initial begin
    $readmemb("input_values.txt", memory);

    for (i = 0; i < 16; i++) begin
      A3 = memory[i][0]; A2 = memory[i][1]; A1 = memory[i][2]; A0 = memory[i][3];
      #5;
    end
  end
endmodule