`timescale  1 ps / 1 ps
module LUT2_original_tb (A, B, C, D, O_ori);
  parameter INIT_NAND = 4'b0111,
            INIT_NOR  = 4'b1000;

  logic input A, B, C, D;
  logic output O_ori;
  logic O_NAND0_ori, O_NAND1_ori, O_NAND2_ori;
  logic [0:3] memory [0:15];
  integer i;
  
  // LUT2 NAND0:
  LUT2 #(.INIT(INIT_NAND)) lut_nand0( .I0(A), .I1(B), .O(O_NAND0_ori) );

  // LUT2 NAND1:
  LUT2 #(.INIT(INIT_NAND)) lut_nand1( .I0(O_NAND0_ori), .I1(C), .O(O_NAND1_ori) );

  // LUT2 NAND2:
  LUT2 #(.INIT(INIT_NAND)) lut_nand2( .I0(C), .I1(D), .O(O_NAND2_ori) );

  // LUT2 NOR:
  LUT2 #(.INIT(INIT_NOR)) lut_nor0( .I0(O_NAND1_ori), .I1(O_NAND2_ori), .O(O_ori) );
  
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
      $display("                Tempo      Entradas LUT      Saídas");
      $display("                         A    B    C    D       O  ");
      $display("                ====   ====================  =======");
      $monitor($time,"     %b    %b    %b    %b       %b    %b    %b    %b", A, B, C, D, O_NAND0, O_NAND1, O_NAND2, O);
    end
  
endmodule
