module decodificador_uart (
    input  logic       clk,
    input  logic       rst,       // Reset ativo alto (mantendo padrão do seu codificador)
    input  logic       rx,        // Entrada serial conectada ao TX do codificador
    output logic [7:0] dados,     // Vetor paralelo (LSB-first)
    output logic       paridade,  // 1 se paridade par correta
    output logic       dv         // Pulso de 1 ciclo indicando dado válido
);

    typedef enum logic [2:0] { 
        AGUARDA     = 3'b000,
        START       = 3'b001,
        REC_DADO    = 3'b010,
        PARIDADE    = 3'b011,
        STOP        = 3'b100
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
    logic [2:0] count_atual, proximo_count;
    logic       paridade_atual, proximo_paridade;
    logic       dv_atual, proximo_dv;

    // Bloco Sequencial: atualiza os estados de todos os registrados (estado da FSM e dos dados armazenados)
    always_ff @( posedge clk or posedge rst) 
    begin: atualiza_estado
        if (rst) begin
            estado_atual        <= AGUARDA;
            dado_recebido_atual <= 8'd0;
            count_atual         <= 3'd0;
            paridade_atual      <= 1'd0;
            dv_atual            <= 1'd0;
        end
        else begin
            estado_atual        <= proximo_estado;
            dado_recebido_atual <= proximo_dado_recebido;
            count_atual         <= proximo_count;
            paridade_atual      <= proximo_paridade;
            dv_atual            <= proximo_dv;
        end
    end

    always_comb 
    begin: transicao_de_estados 
        // default:
        proximo_estado        = estado_atual;
        proximo_dado_recebido = dado_recebido_atual;
        proximo_count         = count_atual;
        proximo_paridade      = paridade_atual;
        proximo_dv            = 1'b0; // Garante que dv_o seja um pulso de apenas 1 ciclo

        case(estado_atual)
            AGUARDA: begin
                proximo_count = 3'd0;   // Zera o contador (count_atual) no próximo ciclo de clock;

                // Detecta o Start Bit (nível lógico 0)
                if (rx == 1'b0) begin
                    proximo_paridade = 1'b0;    // Limpa sinal de paridade
                    proximo_estado = REC_DADO;
                end
            end

            REC_DADO: begin
                proximo_dado_recebido[count_atual] = rx;   // Adiciona o bit rx, segundo a indice dado pelo contador

                // Forma alternativa: lógica de registrador de deslocamento
                // proximo_dado_recebido = {rx, dado_recebido_atual[7:1]};

                proximo_count = count_atual + 3'd1; // Incrementa o contador no próximo ciclo de clock;
                if (count_atual == 3'd7) begin
                    proximo_estado = PARIDADE;
                end
            end

            PARIDADE: begin
                // Paridade PAR: o XOR dos 8 bits de dados deve ser igual ao bit de paridade recebido
                proximo_paridade = (rx == (^dado_recebido_atual));
                proximo_estado  = STOP;
            end

            STOP: begin
                // Valida o Stop Bit (nível lógico 1) e dispara o pulso de dado válido
                if (rx == 1'b1) begin
                    proximo_dv = 1'b1;
                end
                proximo_estado = AGUARDA;
            end

            default: begin
                proximo_estado = AGUARDA;
            end
        endcase
    end

    assign dados    = dado_recebido_atual;
    assign paridade = paridade_atual;
    assign dv       = dv_atual;
endmodule