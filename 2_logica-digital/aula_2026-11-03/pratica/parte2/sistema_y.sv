`timescale 1ns/10ps

module sistema_y
(
  input   logic [3:0] X, REF,
  output  logic Q
);
  logic x0, x1, x2, x3;

  /*
    X == REF

    X[3] == REF[3]  (XNOR3)
    X[2] == REF[2]  (XNOR2)
    X[1] == REF[1]  (XNOR1)
    X[0] == REF[0]  (XNOR0)
      
    AND4 (Q, XNOR3, XNOR2, XNOR1, XNOR0)
  */
  XNOR2X1HVT xnor0(.Y(x0), .A(X[0]), .B(REF[0]));
  XNOR2X1HVT xnor1(.Y(x1), .A(X[1]), .B(REF[1]));
  XNOR2X1HVT xnor2(.Y(x2), .A(X[2]), .B(REF[2]));
  XNOR2X1HVT xnor3(.Y(x3), .A(X[3]), .B(REF[3]));

  AND4X1HVT and4_0(.Y(Q), .A(x3), .B(x2), .C(x1), .D(x0));

endmodule