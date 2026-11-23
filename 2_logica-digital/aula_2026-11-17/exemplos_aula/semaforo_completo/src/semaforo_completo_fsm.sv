module semaforo_completo #(
    parameter TEMPO_VERDE_R1 = 5'd20,
              TEMPO_VERDE_R2 = 5'd30,
              TEMPO_AMARELO  = 5'd5,
              TEMPO_PEDESTRE = 5'd15
)(
    input   logic           clk,
    input   logic           reset,
    input   logic           pedestre,
    input   logic           fast_sim,       // 0 = Normal (100MHz), 1 = Simulação Rápida (10Hz)
    output  logic   [2:0]   sinal_rua1,
    output  logic   [2:0]   sinal_rua2,
    output  logic   [1:0]   sinal_pedestre
);
    logic [26:0] max_count;
    assign max_count = (fast_sim) ? 27'd10 : 27'd100_000_000;

    /*
        REDUZIR CLOCK: Divisor de Clock ou Gerador de Pulso?

        Idealmente, podemos utilizar a lógica de contador para criar um "clock mais lento",
        e usar ele no always @(posedge ...) no lugar do clock original.

        Contudo, criar clocks derivados não é uma boa prática, pois isso pode acabar gerando atraso entre os clocks (clock skew).

        Portanto, ao invés de criar um clock de 1Hz, podemos criar um pulso que ativa a cada 1 segundo, 
        e dura somente um pulso de clock (clock original).
    */
    logic [27:0] clk_counter;
    logic tick_1s_en;

    always_ff @( posedge clk or posedge reset) begin
        if (reset) begin
            clk_counter <= 27'd0;
            tick_1s_en <= 1'b0;
        end
        else if (clk_counter == max_count - 27'd1) begin
            clk_counter <= 27'd0;
            tick_1s_en <= 1'b1;     // Quando a contagem termina, o pulso ativa
        end
        else begin
            clk_counter <= clk_counter + 27'd1;
            tick_1s_en <= 1'b0;     // o pulso se mantém desativado até o fim da contagem
        end
    end

    /*
        TEMPORIZADOR DOS SEMÁFOROS:

        Aqui vamos gerar uma variável de tempo para ficar contando o tempo de duração de cada estado.
        
        Observe que o incremento é feito apenas quando ocorre o pulso. 
        
        Dessa forma, o valor acumulado em "tempo" será equivalente ao tempo, 
        em segundos, de cada estado.
    */
    logic [4:0] tempo;
    logic reset_tempo;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)              tempo <= 5'd0;
        else if (reset_tempo)   tempo <= 5'd0;
        else if (tick_1s_en)    tempo <= tempo + 5'd1;
    end

    /*
        DECLARANDO A MÁQUINA DE ESTADOS (FSM)    

        A estrutura base de uma máquina de estados é composta por essas 3 partes:

            1.  Nomeação dos estados -> Usado para trabalhar a máquina de estados utilizando os nomes
                                        dos estados, ao invés do código binário.
                                        Podemos usar tanto "localparam" ou "enum" (em SystemVerilog apenas) 
                                        para declarar esses nomes.

            2.  Loop Síncrono        -> Usado para atualizar o estado atual

            3.  Loop Combinacional   -> Usado para descrever o comportamento da sua máquina de estado. 
                                        Ou seja, é onde está toda a definição dos estados, transições 
                                        e como as saídas se comportam nesses estados.
    */

    // 1. Nomeação dos estados
    typedef enum logic [2:0] { 
        S0 = 3'b000,
        S1 = 3'b001,
        S2 = 3'b010,
        S3 = 3'b011,
        S4 = 3'b100
    } state_t;

    state_t curr_state, next_state;

    // 2. Loop Síncrono
    always_ff @( posedge clk or posedge reset) begin
        if (reset)  curr_state <= S0;
        else        curr_state <= next_state;
    end

    // 3. Loop Combinacional
    always_comb begin
        // rua[2:0]      =>  [Vermelho, Amarelo, Verde]
        // pedestre[1:0] =>  [Vermelho, Verde]
        
        // valores padrão:
        next_state      =   curr_state;
        reset_tempo     =   1'b0;
        sinal_rua1      =   3'b100;
        sinal_rua2      =   3'b100;
        sinal_pedestre  =   2'b10;

        case(curr_state)
            S0: begin
                sinal_rua1      = 3'b001;   // Verde
                sinal_rua2      = 3'b100;   // Vermelho
                sinal_pedestre  = 2'b10;    // Vermelho

                if (pedestre) begin
                    next_state = S4;
                    reset_tempo = 1'b1;
                end
                else if (tempo == TEMPO_VERDE_R1) begin
                    next_state = S1;
                    reset_tempo = 1'b1;
                end
                else
                    next_state = S0;
            end

            S1: begin
                sinal_rua1      = 3'b010;   // Amarelo
                sinal_rua2      = 3'b100;   // Vermelho
                sinal_pedestre  = 2'b10;    // Vermelho

                if (pedestre) begin
                    next_state = S4;
                    reset_tempo = 1'b1;
                end
                else if (tempo == TEMPO_AMARELO) begin
                    next_state = S2;
                    reset_tempo = 1'b1;
                end
                else
                    next_state = S1;
            end

            S2: begin
                sinal_rua1      = 3'b100;   // Vermelho
                sinal_rua2      = 3'b001;   // Verde
                sinal_pedestre  = 2'b10;    // Vermelho

                if (pedestre) begin
                    next_state = S4;
                    reset_tempo = 1'b1;
                end
                else if (tempo == TEMPO_VERDE_R2) begin
                    next_state = S3;
                    reset_tempo = 1'b1;
                end
                else
                    next_state = S2;
            end

            S3: begin
                sinal_rua1      = 3'b100;   // Vermelho
                sinal_rua2      = 3'b010;   // Amarelo
                sinal_pedestre  = 2'b10;    // Vermelho

                if (pedestre) begin
                    next_state = S4;
                    reset_tempo = 1'b1;
                end
                else if (tempo == TEMPO_AMARELO) begin
                    next_state = S0;
                    reset_tempo = 1'b1;
                end
                else
                    next_state = S3;
            end

            S4: begin
                sinal_rua1      = 3'b100;   // Vermelho
                sinal_rua2      = 3'b100;   // Vermelho
                sinal_pedestre  = 2'b01;    // Verde

                if (tempo == TEMPO_PEDESTRE) begin
                    next_state = S0;
                    reset_tempo = 1'b1;
                end
                else
                    next_state = S4;
            end

            default: next_state = S0;
        endcase
    end
endmodule