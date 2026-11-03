`timescale 1ns/10ps

module full_adder2 (
  input   logic [1:0] A, B,
  input   logic CI,
  output  logic CO,
  output  logic [1:0] S
);

  logic CO_add0;

  // Somador para o bit0:
  ADDFHX1HVT fadd0(
    .CO(CO_add0),
    .S(S[0]),
    .A(A[0]),
    .B(B[0]),
    .CI(CI)
  );

  // Somador para o bit1:
  ADDFHX1HVT fadd1(
    .CO(CO),
    .S(S[1]),
    .A(A[1]),
    .B(B[1]),
    .CI(CO_add0)
  );

endmodule