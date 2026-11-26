module ula32 (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [2:0]  OP,

    output logic [31:0] RESULT,
    output logic Z,
    output logic N,
    output logic C,
    output logic V
);

    logic [32:0] temp;

    always_comb begin

        // Valores iniciais
        RESULT = 32'b0;
        temp   = 33'b0;
        C      = 1'b0;
        V      = 1'b0;

        case (OP)

            3'b000: begin  // ADD
                temp = {1'b0, A} + {1'b0, B};
                RESULT = temp[31:0];
                C = temp[32];

                V = (~(A[31] ^ B[31])) &
                     (A[31] ^ RESULT[31]);
            end

            3'b001: begin  // SUB
                temp = {1'b0, A} - {1'b0, B};
                RESULT = temp[31:0];
                C = ~temp[32];

                V = (A[31] ^ B[31]) &
                    (A[31] ^ RESULT[31]);
            end

            3'b010: begin  // AND
                RESULT = A & B;
            end

            3'b011: begin  // OR
                RESULT = A | B;
            end

            3'b100: begin  // XOR
                RESULT = A ^ B;
            end

            3'b101: begin  // NOT
                RESULT = ~A;
            end

            3'b110: begin  // SLL
                RESULT = A << B[4:0];
            end

            3'b111: begin  // SRL
                RESULT = A >> B[4:0];
            end

            default: begin
                RESULT = 32'b0;
            end

        endcase

        // Flags de estado
        Z = (RESULT == 32'b0);
        N = RESULT[31];

    end

endmodule