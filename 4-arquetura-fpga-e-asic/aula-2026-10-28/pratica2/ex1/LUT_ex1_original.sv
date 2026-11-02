/*
  PRÁTICA 2 - EXERCÍCIO 1: CIRCUITO COMBINACIONAL APENAS COM LUT2
        ___
  A ---|   \ __
       |   |O  \    __
  B ---|__/     \__|  \  ____
                   |   |O    \
  C ---------------|__/       \   ___
          \         __         \__\  \ ____X
           \_______|  \  _________|  /O
                   |   |O        /__/
  D ---------------|__/
*/
module LUT2_circuit_original #(
  parameter INIT_NAND = 4'b0111,
            INIT_NOR  = 4'b1000
) (
  input logic A, B, C, D, 
  output logic O_ori
);
  
  logic O_NAND0, O_NAND1, O_NAND2;
  
  // LUT2 NAND0:
  LUT2 #(.INIT(INIT_NAND)) lut_nand0( .I0(A), .I1(B), .O(O_NAND0) );

  // LUT2 NAND1:
  LUT2 #(.INIT(INIT_NAND)) lut_nand1( .I0(O_NAND0), .I1(C), .O(O_NAND1) );

  // LUT2 NAND2:
  LUT2 #(.INIT(INIT_NAND)) lut_nand2( .I0(C), .I1(D), .O(O_NAND2) );

  // LUT2 NOR:
  LUT2 #(.INIT(INIT_NOR)) lut_nor0( .I0(O_NAND1), .I1(O_NAND2), .O(O_ori) );
endmodule