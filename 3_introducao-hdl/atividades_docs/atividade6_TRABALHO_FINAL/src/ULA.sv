typedef enum logic [2:0] { 
    OP_ADD     = 3'b000,
    OP_AND     = 3'b001,
    OP_OR      = 3'b010,
    OP_NOT     = 3'b011,
    OP_PASS    = 3'b100,
} Op_t;

module ula (
    input   logic   [7:0]   x_i,
    input   logic   [7:0]   y_i,
    input   Op_t            opcode_i,
    output  logic   [7:0]   ula_o,
    output  logic   [1:0]   nz_o
);
    // sinais internos para os sinais de condição:
    logic n, z;

    always_comb begin
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