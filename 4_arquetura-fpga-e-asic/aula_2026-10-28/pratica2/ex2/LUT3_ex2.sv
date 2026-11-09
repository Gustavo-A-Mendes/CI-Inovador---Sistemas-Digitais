module LUT3_circuit_ex2 #(
  parameter INIT_OR   = 8'b1111_1110, // 8'hFE
            INIT_AND  = 8'b1000_0000, // 8'h80
            INIT_NAND = 8'b0111_1111 // 8'h7F
) (
  input logic A0, A1, A2, A3,
  output logic O
);

  logic X0, X3, X1, X2, X4;
  
  // LUT3 OR0:
  LUT3 #(.INIT(INIT_OR)) OR0(.I0(A3), .I1(A2), .I2(A1), .O(X0));

  // LUT3 NAND0:
  LUT3 #(.INIT(INIT_NAND)) NAND0(.I0(A3), .I1(A2), .I2(A0), .O(X1));

  // LUT3 NAND1:
  LUT3 #(.INIT(INIT_NAND)) NAND1(.I0(A3), .I1(A2), .I2(A1), .O(X2));

  // LUT3 OR1:
  LUT3 #(.INIT(INIT_OR)) OR1(.I0(A3), .I1(A2), .I2(A0), .O(X3));

  /* A NAND de 4 entradas tem que dividir em 2 de 3 entradas:

    !(A.B.C.D) = !( (A.B.C) . D . (1'b1) )

    X4 = AND(X0, X1, X2)
    O = NAND(X4, X3, 1'b1)

  */
  // LUT3 AND0:
  LUT3 #(.INIT(INIT_AND)) AND0(.I0(X0), .I1(X1), .I2(X2), .O(X4));

  // LUT3 NAND2:
  LUT3 #(.INIT(INIT_NAND)) NAND2(.I0(X4), .I1(X3), .I2(1'b1), .O(O));
endmodule