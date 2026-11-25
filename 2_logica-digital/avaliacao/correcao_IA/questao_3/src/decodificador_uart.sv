module decodificador_uart (
    input  logic       clk,
    input  logic       reset,       // Reset ativo alto (mantendo padrão do seu codificador)
    input  logic       RX,        // Entrada serial conectada ao TX do codificador
    output logic       dado_valido,         // Pulso de 1 ciclo indicando dado válido
    output logic [7:0] dado,     // Vetor paralelo (LSB-first)
    output logic       paridade,  // 1 se paridade par correta
    output logic       inicio
);

    typedef enum logic [3:0] { 
        AGUARDA     = 4'b0000,
        REC_D0      = 4'b0001,
        REC_D1      = 4'b0010,
        REC_D2      = 4'b0011,
        REC_D3      = 4'b0100,
        REC_D4      = 4'b0101,
        REC_D5      = 4'b0110,
        REC_D6      = 4'b0111,
        REC_D7      = 4'b1000,
        PARIDADE    = 4'b1001,
        STOP        = 4'b1010
    } state_t;

    state_t estado_atual, proximo_estado;

    // sinais para sincronismo:
    /*
        Idealmente, o codificador e o decodificador compartilham do mesmo sinal de clock.

        Porém, no mundo real, os hardwares de cada um podem não estar sincronizados.
        Portanto, a ideia é salvar esses sinais em um registrador, mas evitar erros
        devido a falta de sincronismo.

        Vamos ter uma defasagem de 1 ciclo de clock entre o recebimento/acionamento,
        mas vamos ter proteção contra metaestabilidade.
    */
    logic [7:0] dado_recebido_atual, proximo_dado_recebido;
    logic       paridade_q;

    // Bloco Sequencial: atualiza os estados de todos os registrados (estado da FSM e dos dado armazenados)
    always_ff @( posedge clk) 
    begin: atualiza_estado
        if (reset) begin
            estado_atual        <= AGUARDA;
            dado_recebido_atual <= 8'd0;
            paridade            <= 1'b0;
        end
        else begin
            estado_atual        <= proximo_estado;
            dado_recebido_atual <= proximo_dado_recebido;
            paridade            <= paridade_q;
        end
    end

    always_comb 
    begin: transicao_de_estados 
        // default:
        inicio                  =   1'b0;
        proximo_estado          =   estado_atual;
        proximo_dado_recebido   =   dado_recebido_atual;
        dado_valido             =   1'b0;
        paridade_q              =   1'b0;

        case(estado_atual)
            AGUARDA: begin
                // Detecta o Start Bit (nível lógico 0)
                if (RX == 1'b0) begin
                    inicio          =   1'b1;
                    proximo_estado  =   REC_D0;
                end
            end

            REC_D0: begin
                proximo_dado_recebido[0] = RX;
                proximo_estado  =   REC_D1;
            end

            REC_D1: begin
                proximo_dado_recebido[1] = RX;
                proximo_estado  =   REC_D2;
            end

            REC_D2: begin
                proximo_dado_recebido[2] = RX;
                proximo_estado  =   REC_D3;
            end

            REC_D3: begin
                proximo_dado_recebido[3] = RX;
                proximo_estado  =   REC_D4;
            end

            REC_D4: begin
                proximo_dado_recebido[4] = RX;
                proximo_estado  =   REC_D5;
            end

            REC_D5: begin
                proximo_dado_recebido[5] = RX;
                proximo_estado  =   REC_D6;
            end

            REC_D6: begin
                proximo_dado_recebido[6] = RX;
                proximo_estado  =   REC_D7;
            end

            REC_D7: begin
                proximo_dado_recebido[7] = RX;
                proximo_estado  =   PARIDADE;
            end

            PARIDADE: begin
                // Paridade PAR: o XOR dos 8 bits de dado deve ser igual ao bit de paridade recebido
                paridade_q      =   RX;
                proximo_estado  =   STOP;
            end

            STOP: begin
                // Valida o Stop Bit (nível lógico 1) e dispara o pulso de dado válido
                if (RX == 1'b1) begin
                    dado_valido = 1'b1;
                end
                proximo_estado = AGUARDA;
            end

            default: begin
                proximo_estado = AGUARDA;
            end
        endcase
    end

    assign dado    = dado_recebido_atual;
endmodule
