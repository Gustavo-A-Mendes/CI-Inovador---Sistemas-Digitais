module dec_encoder_rotativo (
    input   logic           clk,    // Tclk = 100ns => f = 10MHz
    input   logic           reset,
    input   logic           a,
    input   logic           b,
    output  logic           passo_a,
    output  logic           passo_b,
    output  logic           volta_a,
    output  logic           volta_b
);
    
    /*
        Registradores (shift register) para Sincronização (2-FF):

        Garante estabilidade para sinais que podem estar em assincronia com o clock do circuito.

        Gera uma latência extra (1 ciclo de clock para cada bit registrado), 
        mas protege contra metaestabilidade.
    */
    // [0] = metaestável, [1] = sincronizado
    logic [1:0] a_sync_q, b_sync_q;

    always_ff @( posedge clk ) 
    begin : sincronizacao_ff
        if (reset) begin
            a_sync_q <= 2'b00;
            b_sync_q <= 2'b00;
        end else begin
            a_sync_q <= {a_sync_q[0], a};
            b_sync_q <= {b_sync_q[0], b};
        end
    end

    //
    logic [1:0] ab_sync;
    assign ab_sync = {a_sync_q[1], b_sync_q[1]};

    // 2. Montagem da FSM
    typedef enum logic [2:0] { 
        IDLE        =   3'd0,   // ab = 00
        // Caminho 1: (A -> B: 00 -> 10 -> 11 -> 01 -> 00)
        CAMINHO1_1  =   3'd1,   // ab = 10
        CAMINHO1_2  =   3'd2,   // ab = 11
        CAMINHO1_3  =   3'd3,   // ab = 01
        // Caminho 2: (B -> A: 00 -> 01 -> 11 -> 10 -> 00)
        CAMINHO2_1  =   3'd4,   // ab = 01
        CAMINHO2_2  =   3'd5,   // ab = 11
        CAMINHO2_3  =   3'd6    // ab = 10
    } estados_t;

    estados_t estado_atual, prox_estado;
    logic step_a, step_b;

    always_comb 
    begin
        // valores padrão:
        prox_estado =   estado_atual;
        step_a      =   1'b0;
        step_b      =   1'b0;

        case (estado_atual)
            IDLE: begin
                if (ab_sync == 2'b10)       prox_estado = CAMINHO1_1;   // Detecta caminho A -> B
                else if (ab_sync == 2'b01)  prox_estado = CAMINHO2_1;   // Detecta caminho B -> A
                else                        prox_estado = IDLE;
            end
            // =============== CAMINHO 1 ===============
            CAMINHO1_1: begin   // ab = 10
                if (ab_sync == 2'b11)       prox_estado = CAMINHO1_2;   // Avança
                else if (ab_sync == 2'b10)  prox_estado = CAMINHO1_1;   // Mantém
                else if (ab_sync == 2'b00)  prox_estado = IDLE;         // Recuou
                else                        prox_estado = IDLE;
            end

            CAMINHO1_2: begin   // ab = 11
                if (ab_sync == 2'b01)       prox_estado = CAMINHO1_3;   // Avança
                else if (ab_sync == 2'b11)  prox_estado = CAMINHO1_2;   // Mantém
                else if (ab_sync == 2'b10)  prox_estado = CAMINHO1_1;   // Recuou
                else                        prox_estado = IDLE;
            end

            CAMINHO1_3: begin   // ab = 01
                if (ab_sync == 2'b00) begin // Avança
                    prox_estado = IDLE;
                    step_a = 1'b1;  // Detecta um passo no sentido A -> B
                end       
                else if (ab_sync == 2'b01)  prox_estado = CAMINHO1_3;   // Mantém
                else if (ab_sync == 2'b11)  prox_estado = CAMINHO1_2;   // Recuou
                else                        prox_estado = IDLE;
            end
            // =============== CAMINHO 2 ===============
            CAMINHO2_1: begin   // ab = 01
                if (ab_sync == 2'b11)       prox_estado = CAMINHO2_2;   // Avança
                else if (ab_sync == 2'b01)  prox_estado = CAMINHO2_1;   // Mantém
                else if (ab_sync == 2'b00)  prox_estado = IDLE;         // Recuou
                else                        prox_estado = IDLE;
            end

            CAMINHO2_2: begin   // ab = 11
                if (ab_sync == 2'b10)       prox_estado = CAMINHO2_3;   // Avança
                else if (ab_sync == 2'b11)  prox_estado = CAMINHO2_2;   // Mantém
                else if (ab_sync == 2'b01)  prox_estado = CAMINHO2_1;   // Recuou
                else                        prox_estado = IDLE;
            end

            CAMINHO2_3: begin   // ab = 10
                if (ab_sync == 2'b00) begin // Avança
                    prox_estado = IDLE;
                    step_b = 1'b1;  // Detecta um passo no sentido B -> A
                end       
                else if (ab_sync == 2'b10)  prox_estado = CAMINHO2_3;   // Mantém
                else if (ab_sync == 2'b11)  prox_estado = CAMINHO2_2;   // Recuou
                else                        prox_estado = IDLE;
            end

            default: prox_estado = IDLE;
        endcase
    end

    /*
        3. Contador de Passos Líquida

        O encoder incremental conta o deslocamento líquido, ou seja, soma ou subtrai conforme o sentido do giro,
        a partir do ponto em que ele foi ligado (ou zerado).

        Portanto, definindo o sentido positivo como a direcao A e o negativo, B:
          - volta_a só ativa quando o contador estiver em +16 ('b0_1111)
          - volta_b só ativa quando o contador estiver em -16 ('b1_0001)
    */
    logic signed [4:0]  count_liq_atual, prox_count_liq;
    logic               prox_volta_a, prox_volta_b;

    always_comb begin
        prox_count_liq  =   count_liq_atual;
        prox_volta_a    =   1'b0;
        prox_volta_b    =   1'b0;

        if (step_a) begin
            if (count_liq_atual == 5'sd15) begin
                prox_volta_a    = 1'b1;
                prox_count_liq  = 5'd0;
            end else begin
                prox_count_liq  = count_liq_atual + 5'sd1;
            end
        end 
        else if (step_b) begin
            if (count_liq_atual == -5'sd15) begin
                prox_volta_b    = 1'b1;
                prox_count_liq  = 5'd0;
            end else begin
                prox_count_liq  = count_liq_atual - 5'sd1;
            end
        end
    end

    // Bloco sequencial (Sincronização):
    always_ff @(posedge clk ) begin
        if (reset) begin
            estado_atual    <= IDLE;
            count_liq_atual <= 6'sd0;
            passo_a         <= 1'b0;
            passo_b         <= 1'b0;
            volta_a         <= 1'b0;
            volta_b         <= 1'b0;
        end else begin
            estado_atual    <= prox_estado;
            count_liq_atual <= prox_count_liq;
            passo_a         <= step_a;
            passo_b         <= step_b;
            volta_a         <= prox_volta_a;
            volta_b         <= prox_volta_b;
        end
    end
endmodule