`timescale 1ns/1ps

module tb_multiplexador_ula;

    logic [2:0] A, B;
    logic OP;
    logic [3:0] Q;

    // Instancia do módulo
    multiplexador_ula mula0(.*);

    initial begin
        A = 3'd0; B = 3'd0; OP = 1'b0;

        #10;

        $dumpfile("multiplexador_result.vcd");
        $dumpvars(0, tb_multiplexador_ula);

        // Estimulos:
        A = 3'd3; B = 3'd2;     // Saída esperada: Q = 4'b0001 (5)

        #10;

        OP = 1'b1;              // Saída esperada: Q = 4'b0101 (5)

        #10;

        // Testar bit carry de Q
        A = 3'd4; B = 3'd6; OP = 1'b0;  // Saída esperada: Q = 4'b1001 (9 ou -7 em complemento de 2)

        #10;

        OP = 1'b1;                      // Saída esperada: Q = 4'b1110 (-2 ou 14 em complemento de 2)

        $finish;
    end

endmodule