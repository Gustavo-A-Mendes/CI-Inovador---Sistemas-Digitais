module codificador_uart (
    input   logic           clk,
    input   logic           reset,
    input   logic   [7:0]   dado,
    input   logic           dado_valido,
    input   logic           stop_1_2,
    output  logic           TX,
    output  logic           transmitindo,
    output  logic           fim
);

    typedef enum logic [3:0] { 
        AGUARDA_DADO    =   4'd0,
        GERA_START      =   4'd1,
        TRANS_D0        =   4'd2,
        TRANS_D1        =   4'd3,
        TRANS_D2        =   4'd4,
        TRANS_D3        =   4'd5,
        TRANS_D4        =   4'd6,
        TRANS_D5        =   4'd7,
        TRANS_D6        =   4'd8,
        TRANS_D7        =   4'd9,
        TRANS_PARIDADE  =   4'd10,
        GERA_STOP1      =   4'd11,
        GERA_STOP2      =   4'd12,
    } state_t;

    state_t curr_state, next_state;

    always_ff @( posedge clk or posedge reset ) begin
        if (reset) curr_state <= AGUARDA_DADO;
        else       curr_state <= next_state
    end

    always_comb begin
        TX = 1'b1;              // por padrão, a saída fica em nível lógico alto
        transmitindo = 1'b1;    // por padrão, está transmitindo
        fim = 1'b0;
        
        next_state = curr_state;

        case (curr_state)
            AGUARDA_DADO: begin
                transmitindo = 1'b0;
                
                if (dado_valido)    next_state = GERA_START;
            end

            GERA_START: begin
                TX = 1'b0;  // Start é um bit de nível lógico baixo
                
                next_state = TRANS_D0;
            end

            TRANS_D0: begin
                TX = dado[0];
                
                next_state = TRANS_D1;
            end

            TRANS_D1: begin
                TX = dado[1];
                
                next_state = TRANS_D2;
            end

            TRANS_D2: begin
                TX = dado[2];
                
                next_state = TRANS_D3;
            end

            TRANS_D3: begin
                TX = dado[3];
                
                next_state = TRANS_D4;
            end

            TRANS_D4: begin
                TX = dado[4];
                
                next_state = TRANS_D5;
            end

            TRANS_D5: begin
                TX = dado[5];
                
                next_state = TRANS_D6;
            end

            TRANS_D6: begin
                TX = dado[6];
                
                next_state = TRANS_D7;
            end

            TRANS_D7: begin
                TX = dado[7];
                
                next_state = TRANS_PARIDADE;
            end

            TRANS_PARIDADE: begin
                TX = (^dado);   // XOR de dados transmitidos
                
                next_state = GERA_STOP;
            end

            GERA_STOP1: begin
                TX = 1'b1;  // stop é nível lógico alto
                fim = 1'b1;
                transmitindo = 1'b1;

                if (stop_1_2)   next_state = GERA_STOP2;
                else begin
                    if (dado_valido)    next_state = GERA_START;
                    else                next_state = AGUARDA_DADO;
                end
            end

            GERA_STOP2: begin
                TX = 1'b1;  // stop é nível lógico alto
                transmitindo = 1'b1;

                if (dado_valido)    next_state = GERA_START;
                else                next_state = AGUARDA_DADO;
            end
        endcase
    end
endmodule