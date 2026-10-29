`timescale  1 ps / 1 ps
module LUT3_tb;
  parameter INIT_OR =   8'hFE,
            INIT_NAND = 8'h7F;

  logic A0, A1, A2, A3;
  logic O_OR0, O_OR1, O_NAND0, O_NAND1, O_NAND2, O;
  logic [0:3] memory [0:15];
  integer i;
  
  // LUT3 OR0:
  LUT3 #(.INIT(INIT_OR)) OR0(.I0(A3), .I1(A2), .I2(A1), .O(O_OR0));

  // LUT3 NAND0:
  LUT3 #(.INIT(INIT_NAND)) NAND0(.I0(A3), .I1(A2), .I2(A0), .O(O_NAND0));

  // LUT3 NAND1:
  LUT3 #(.INIT(INIT_NAND)) NAND1(.I0(A3), .I1(A2), .I2(A1), .O(O_NAND1));

  // LUT3 OR1:
  LUT3 #(.INIT(INIT_OR)) OR1(.I0(A3), .I1(A2), .I2(A0), .O(O_OR1));

  /* A NAND de 4 entradas tem que dividir em 2 de 3 entradas:

    !(A.B.C.D) = !(A.B.C) + !D

    O_NAND2 = NAND(O_OR0, 0_NAND0, 0_NAND1)
    O = OR(O_NAND2, ~O_OR1, 1'b0)

  */
  // LUT3 NAND2:
  LUT3 #(.INIT(INIT_NAND)) NAND2(.I0(O_OR0), .I1(O_NAND0), .I2(O_NAND1), .O(O_NAND2));

  // LUT3 OR2:
  LUT3 #(.INIT(INIT_OR)) NAND3(.I0(O_NAND2), .I1(~O_OR1), .I2(1'b0), .O(O));
  
  initial
    begin
      $readmemb("input_values.txt", memory);

      for (i = 0; i < 16; i++) begin
        A3 = memory[i][0]; A2 = memory[i][1]; A1 = memory[i][2]; A0 = memory[i][3];
        #5;
      end
    end
  
  initial
    begin
      $display("                Tempo      Entradas LUT      Saídas");
      $display("                         A3    A2    A1    A0     OR0 NAND0 NAND1 OR1 NAND2  O  ");
      $display("                ====   ========================  ================================");
      $monitor($time,"      %b     %b     %b     %b       %b    %b    %b    %b    %b    %b", A3, A2, A1, A0, O_OR0, O_NAND0, O_NAND1, O_OR1, O_NAND2, O);

      $finish;
    end
  
endmodule
