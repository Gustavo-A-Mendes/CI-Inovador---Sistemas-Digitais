`timescale 1ns/10ps

module sistema_x
(
  input   logic [3:0] X,
  output  logic Q
);
  logic x1, x2;

  /*
    X == 1001

    1001 == X[3] & (~X[2]) & (~X[1]) & X[0]
      
  */
  INVX1HVT inv1(.Y(x1), .A(X[1]));
  INVX1HVT inv2(.Y(x2), .A(X[2]));

  AND4X1HVT and4_0(.Y(Q), .A(X[3]), .B(x2), .C(x1), .D(X[0]));

endmodule