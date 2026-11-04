module bit_counter #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  s,
    input  wire [DATA_WIDTH-1:0] A_in,
    output reg  [DATA_WIDTH-1:0] B,
    output reg                   done
);

    // Definição dos estados
    localparam S1 = 2'b00;
    localparam S2 = 2'b01;
    localparam S3 = 2'b10;

    reg [1:0] state, next_state;
    reg [DATA_WIDTH-1:0] A;

    // Lógica do registo de Estado e Datapath
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S1;
            A     <= {DATA_WIDTH{1'b0}};
            B     <= {DATA_WIDTH{1'b0}};
        end else begin
            state <= next_state;

            case (state)
                S1: begin
                    B <= {DATA_WIDTH{1'b0}};
                    if (!s) begin
                        A <= A_in; // Load A
                    end
                end

                S2: begin
                    // Shift right A
                    A <= A >> 1;

                    // Atualização de B baseada na condição a0 (antes do deslocamento)
                    if ((A >> 1) != 0 && A[0]) begin
                        B <= B + 1'b1;
                    end else if (A != 0 && (A >> 1) == 0 && A[0]) begin
                        B <= B + 1'b1;
                    end
                end

                S3: begin
                    // Mantém os valores até voltar a S1
                end

                default: state <= S1;
            endcase
        end
    end

    // Lógica do Próximo Estado
    always @(*) begin
        case (state)
            S1: begin
                if (s)
                    next_state = S2;
                else
                    next_state = S1;
            end

            S2: begin
                // Após o shift right, verifica se A se tornou 0
                if ((A >> 1) == 0)
                    next_state = S3;
                else
                    next_state = S2;
            end

            S3: begin
                if (s)
                    next_state = S3;
                else
                    next_state = S1;
            end

            default: next_state = S1;
        endcase
    end

    // Lógica de Saída (Done)
    always @(*) begin
        done = (state == S3);
    end

endmodule