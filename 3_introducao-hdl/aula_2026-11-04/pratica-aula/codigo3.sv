module fsm (
    input  wire clk,
    input  wire reset,
    input  wire S,
    input  wire zeroA,
    input  wire zeroA0,
    output reg  shiftR,
    output reg  Loada,
    output reg  Done,
    output reg  Incb,
    output reg  Rstb
);

    // Definição dos estados (One-Hot ou Binary Encoding)
    parameter S1   = 2'b00,
              S2   = 2'b01,
              DONE = 2'b10;

    reg [1:0] current_state, next_state;

    // Registo de estado (Transições sincronizadas pelo clock)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S1;
        end else begin
            current_state <= next_state;
        end
    end

    // Lógica do próximo estado (Combinatória)
    always @(*) begin
        case (current_state)
            S1: begin
                if (S == 1'b1)
                    next_state = S2;
                else
                    next_state = S1; // Permanece em S1 enquanto S=0
            end

            S2: begin
                if (zeroA == 1'b1)
                    next_state = DONE;
                else
                    next_state = S2; // Permanece em S2 enquanto zeroA=0
            end

            DONE: begin
                if (S == 1'b0)
                    next_state = S1;
                else
                    next_state = DONE; // Permanece em DONE enquanto S=1
            end

            default: next_state = S1;
        endcase
    end

    // Lógica das saídas (Moore Output FSM)
    always @(*) begin
        // Valores padrão (para evitar latches)
        shiftR = 1'b0;
        Loada  = 1'b0;
        Done   = 1 me; // Ajuste por estado abaixo
        Incb   = 1'b0;
        Rstb   = 1'b0;

        case (current_state)
            S1: begin
                shiftR = 1'b0;
                Done   = 1'b0;
                Incb   = 1'b0;
                Rstb   = 1'b1;
                // No transição de auto-loop S=0, Loada=1; caso contrário Loada=0
                if (S == 1'b0)
                    Loada = 1'b1;
                else
                    Loada = 1'b0;
            end

            S2: begin
                shiftR = 1'b1;
                Loada  = 1'b0;
                Done   = 1'b0;
                Rstb   = 1'b0;
                
                // Saída incB depende de zeroA e zeroA0 durante o estado S2
                if (zeroA == 1'b0 && zeroA0 == 1'b1)
                    Incb = 1'b1;
                else
                    Incb = 1'b0;
            end

            DONE: begin
                Done   = 1'b1;
                shiftR = 1'b0;
                Loada  = 1'b0;
                Incb   = 1'b0;
                Rstb   = 1'b0;
            end

            default: begin
                shiftR = 1'b0;
                Loada  = 1'b0;
                Done   = 1'b0;
                Incb   = 1'b0;
                Rstb   = 1'b0;
            end
        endcase
    end

endmodule