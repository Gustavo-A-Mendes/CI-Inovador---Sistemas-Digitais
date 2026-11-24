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
    // [0] = metaestável, [1] = sincronizado, [2] = estado anterior
    logic [2:0] a_sync_q, b_sync_q;

    always_ff @( posedge clk ) 
    begin : sincronizacao_2ff
        if (reset) begin
            a_sync_q <= 3'b000;
            b_sync_q <= 3'b000;
        end else begin
            a_sync_q <= {a_sync_q[1:0], a};
            b_sync_q <= {b_sync_q[1:0], b};
        end
    end

    // Determinar sinais atual e anterior:
    logic a_atual, a_anterior;
    logic b_atual, b_anterior;

    assign a_atual      = a_sync_q[1];
    assign a_anterior   = a_sync_q[2];
    assign b_atual      = b_sync_q[1];
    assign b_anterior   = b_sync_q[2];

    // 2. Detecção de borda de subida (com sinais sincronizados)
    logic subida_a, subida_b;
    assign subida_a = ( (a_atual == 1'b1) && (a_anterior == 1'b0) );
    assign subida_b = ( (b_atual == 1'b1) && (b_anterior == 1'b0) );

    // Lógica dos passos
    logic step_a, step_b;
    assign step_a = ( (subida_a == 1'b1) && (b_atual == 1'b0) );
    assign step_b = ( (subida_b == 1'b1) && (a_atual == 1'b0) );

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

    always_comb 
    begin
        // valores padrão:
        prox_count_liq  =   count_liq_atual;
        prox_volta_a    =   1'b0;
        prox_volta_b    =   1'b0;

        if (step_a) begin
            if (count_liq_atual == 5'sd15) begin
                prox_volta_a    = 1'b1;
                prox_count_liq  = 5'd0;
            end else begin
                prox_count_liq  = count_liq_atual + 1;
            end
        end 
        else if (step_b) begin
            if (count_liq_atual == -5'sd15) begin
                prox_volta_b    = 1'b1;
                prox_count_liq  = 5'd0;
            end else begin
                prox_count_liq  = count_liq_atual - 1;
            end
        end
    end

    always_ff @( posedge clk ) 
    begin
        if (reset) begin
            volta_a         <=  1'b0;
            volta_b         <=  1'b0;
            passo_a         <=  1'b0;
            passo_b         <=  1'b0;
            count_liq_atual <=  5'sd0;
        end
        else begin
            volta_a         <=  prox_volta_a;
            volta_b         <=  prox_volta_b;
            passo_a         <=  step_a;
            passo_b         <=  step_b;
            count_liq_atual <=  prox_count_liq;
        end
    end
endmodule