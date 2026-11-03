module LUT23_circuit_ex3 #(
  parameter INIT_XOR2 = 4'b0110,      // 4'h6
            INIT_AND2 = 4'b1000,      // 4'h8
            INIT_OR3  = 8'b1111_1110  // 8'hFE
) (
  input logic A, B, Cin,
  output logic S, Cout
);
  
  // Saídas intermediárias:
  logic X0, X1, X2, X3;

  // LUT2 XOR0:
  LUT2 #(.INIT(INIT_XOR2)) XOR0(.I0(B), .I1(Cin), .O(X0));

  // LUT2 AND0:
  LUT2 #(.INIT(INIT_AND2)) AND0(.I0(B), .I1(Cin), .O(X1));

  // LUT2 AND1:
  LUT2 #(.INIT(INIT_AND2)) AND1(.I0(B), .I1(A), .O(X2));

  // LUT2 AND2:
  LUT2 #(.INIT(INIT_AND2)) AND2(.I0(A), .I1(Cin), .O(X3));

  // LUT2 XOR1:
  LUT2 #(.INIT(INIT_XOR2)) XOR1(.I0(A), .I1(X0), .O(S));

  // LUT3 OR0:
  LUT3 #(.INIT(INIT_OR3)) OR0(.I0(X1), .I1(X2), .I2(X3), .O(Cout));
endmodule