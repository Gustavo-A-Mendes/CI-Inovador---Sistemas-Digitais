`timescale 1ns/1ps

import neander_pkg::*;

module ula (
    input   logic       [7:0]   x_i,
    input   logic       [7:0]   y_i,
    input   ula_op_t            opcode_i,
    output  logic       [7:0]   ula_o,
    output  logic       [1:0]   nz_o
);
    // sinais internos para os sinais de condição:
    logic n, z;

    always_comb begin
        ula_o = 8'h00;  // Valor default

        unique case(opcode_i)
            OP_ADD:     ula_o = x_i + y_i;
            OP_AND:     ula_o = x_i & y_i;
            OP_OR:      ula_o = x_i | y_i;
            OP_NOT:     ula_o = ~x_i;
            OP_PASS:    ula_o = y_i;
        endcase

        n = ula_o[7];           // Em complemento de 2, o bit mais significativo é o bit de sinal
        z = (ula_o == 8'b0);    // Saída da ULA é igual a 0
    end

    assign nz_o = {n, z};

endmodule