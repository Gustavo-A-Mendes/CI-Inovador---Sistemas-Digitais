`timescale  1 ps / 1 ps
module LUT2_simplified_tb (A, B, C, D, O_simp);
  parameter INIT_NAND = 4'b0111,
            INIT_AND  = 4'b1000;

  logic input A, B, C, D;
  logic output O_simp;
  logic O_NAND0_simp, O_AND0_simp;
  logic [0:3] memory [0:15];
  integer i;
  
  /*

    !( !( !(A.B) . C ) + !( C.D ) ) === ( !(A.B).(C.D) )

    1 NAND e 2 AND

  */

  // LUT2 NAND0:
  LUT2 #(.INIT(INIT_NAND)) lut_nand0( .I0(A), .I1(B), .O(O_NAND0_simp) );

  // LUT2 AND0:
  LUT2 #(.INIT(INIT_AND)) lut_and0( .I0(C), .I1(D), .O(O_AND0_simp) );

  // LUT2 AND1:
  LUT2 #(.INIT(INIT_AND)) lut_and1( .I0(O_NAND0_simp), .I1(O_AND0_simp), .O(O_simp) );
  
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
      $monitor($time,"     %b    %b    %b    %b       %b", A, B, C, D, O);
    end
  
endmodule
