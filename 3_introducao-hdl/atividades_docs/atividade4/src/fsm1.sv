module fsm1 (
    input   logic clk_i,
    input   logic rst_n_i,
    input   logic B_i,                // Entrada de Controle
    input   logic timer_i,            // Sinal de Status

    output  logic LED_o,              // Saída de Controle
    output  logic rst_int_n_o, start_o,  // Sinal de Controle
    output  logic [2:0] state_o
    );

    typedef enum logic [2:0] { 
        ST_S0 = 3'b000,
        ST_S1 = 3'b001,
        ST_S2 = 3'b010,
        ST_S3 = 3'b011,
        ST_S4 = 3'b100
    } State_t;

    State_t curr_state_q, next_state_d;

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)   curr_state_q <= ST_S0;
        else            curr_state_q <= next_state_d;
    end

    always_comb begin
        // Inicializa as saídas limpas:
        LED_o = 1'b0; start_o = 1'b0; rst_int_n_o = 1'b1;
        next_state_d = ST_S0;

        case(curr_state_q)
            ST_S0: begin   // '_ _ _'
                rst_int_n_o = 1'b0;

                if (B_i)    next_state_d = ST_S1;
                else        next_state_d = ST_S0;
            end
            
            ST_S1: begin   // '1 _ _'
                if (B_i)    next_state_d = ST_S1;
                else        next_state_d = ST_S2;
            end

            ST_S2: begin   // '1 0 _'
                if (B_i)    next_state_d = ST_S3;
                else        next_state_d = ST_S2;
            end

            ST_S3: begin   // '1 0 1'
                LED_o = 1'b1;
                start_o = 1'b1;

                if (timer_i)    next_state_d = ST_S4;
                else if (B_i)   next_state_d = ST_S3;
            end

            ST_S4: begin   // '1 0 1'
                if (!B_i) next_state_d = ST_S0;
                else    next_state_d = ST_S1;
            end
            
            default:    next_state_d = ST_S0;
        endcase
    end

    assign state_o = curr_state_q;
endmodule