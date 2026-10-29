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
            INIT_NOR  = 4'b0001
) (
  input logic A, B, C, D, 
  output logic O_ori
);
  
  logic X0, X1, X2;
  
  // LUT2 NAND0:
  LUT2 #(.INIT(INIT_NAND)) lut_nand0( .I0(A), .I1(B), .O(X0) );

  // LUT2 NAND1:
  LUT2 #(.INIT(INIT_NAND)) lut_nand1( .I0(X0), .I1(C), .O(X1) );

  // LUT2 NAND2:
  LUT2 #(.INIT(INIT_NAND)) lut_nand2( .I0(C), .I1(D), .O(X2) );

  // LUT2 NOR:
  LUT2 #(.INIT(INIT_NOR)) lut_nor0( .I0(X1), .I1(X2), .O(O_ori) );
endmodule