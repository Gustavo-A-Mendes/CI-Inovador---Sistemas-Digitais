`timescale 1ns/10ps

module meu_primeiro_mux8x1 (
  input   logic EN,
  input   logic [2:0] A,
  input   logic [7:0] X,
  output  logic Q
);
    
  /*
    X = [H, G, F, E, D, C, B, A]
                                                               |
             A[0]              A[1]            A[2]            |             A[1:0]              A[2]
              |                 |               |              |                |                 |
          ____|____             |               |              |                |                 |
      A---|       |             |               |              |                |                 |
          | MX2X1 |-----|       |               |              |                |                 |
      B---|_______|     |   ____|____           |              |                |                 |
              .         |---|       |           |              |            ____|____             |
              .             | MX2X1 |---|       |              |        A---|       |             |
          ____|____     |---|_______|   |       |              |            |       |             |
      C---|       |     |               |       |              |        B---|       |             |
          | MX2X1 |-----|               |       |              |            | MX4X1 |-----|       |
      D---|_______|                     |   ____|____          |        C---|       |     |       |
              .                         |---|       |          |            |       |     |       |
              .                             | MX2X1 |--- Q     |        D---|_______|     |   ____|____
          ____|____                     |---|_______|          |                .         |---|       |
      E---|       |             .       |                      |                .             | MX2X1 |--- Q
          | MX2X1 |-----|       .       |                      |            ____|____     |---|_______|
      F---|_______|     |   ____|____   |                      |        E---|       |     |
              .         |---|       |   |                      |            |       |     |
              .             | MX2X1 |---|                      |        F---|       |     |
          ____|____     |---|_______|                          |            | MX4X1 |-----|
      G---|       |     |                                      |        G---|       |      
          | MX2X1 |-----|                                      |            |       |
      H---|_______|                                            |        H---|_______|
                                                               |
  */

  logic x0, x1, result;

  // 1ª Camada: MUX 4x1 para metade inferior X[3:0]
  MX4X1HVT mux4_0(
    .Y(x0), 
    .A(X[0]),
    .B(X[1]),
    .C(X[2]),
    .D(X[3]),
    .S0(A[0]),
    .S1(A[1])
  );

  // 1ª Camada: MUX 4x1 para metade superior X[7:4]
  MX4X1HVT mux4_1(
    .Y(x1), 
    .A(X[4]),
    .B(X[5]),
    .C(X[6]),
    .D(X[7]),
    .S0(A[0]),
    .S1(A[1])
  ); 

  // 2ª Camada: Seleciona entre x0 e x1
  MX2X1HVT mux2_0(
    .Y(result), 
    .A(x0),
    .B(x1),
    .S0(A[2])
  ); 

  // 3ª Camada (Enable): Bloqueia ou libera a saída Q
  // Se EN == 0 -> Q = 1'b0 (A)
  // Se EN == 1 -> Q = result (B)
  AND2X1HVT and_en(
    .Y(Q), 
    .A(result),
    .B(EN)
  );

endmodule