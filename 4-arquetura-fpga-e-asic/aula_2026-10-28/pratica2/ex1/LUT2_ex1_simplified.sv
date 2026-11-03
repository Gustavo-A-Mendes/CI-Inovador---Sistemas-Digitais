/*
  PRÁTICA 2 - EXERCÍCIO 1: CIRCUITO COMBINACIONAL APENAS COM LUT2
        ___
  A ---|   \ __
       |   |O  \    __
  B ---|__/     \__|  \  ____ X
                 __|   |
        ___     /  |__/
  C ---|   \ __/
       |   |
  D ---|__/

  !( !( !(A.B) . C ) + !( C.D ) ) === ( !(A.B).(C.D) )

  1 NAND e 2 AND
*/
module LUT2_circuit_simplified #(
  parameter INIT_NAND = 4'b0111,
            INIT_AND  = 4'b1000
) (
  input logic A, B, C, D, 
  output logic O_simp
);
  
  logic O_NAND0, O_AND0;

  // LUT2 NAND0:
  LUT2 #(.INIT(INIT_NAND)) lut_nand0( .I0(A), .I1(B), .O(O_NAND0) );

  // LUT2 AND0:
  LUT2 #(.INIT(INIT_AND)) lut_and0( .I0(C), .I1(D), .O(O_AND0) );

  // LUT2 AND1:
  LUT2 #(.INIT(INIT_AND)) lut_and1( .I0(O_NAND0), .I1(O_AND0), .O(O_simp) );
endmodule