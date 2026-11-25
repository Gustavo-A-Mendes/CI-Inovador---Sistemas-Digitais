module cdma_align (
    input  logic       clk,
    input  logic       reset,
    input  logic       di,
    input  logic [7:0] padrao,
    output logic       encontrado,
    output logic [9:0] atraso
);

    // sinais internos:
    logic   [9:0]   delay_count_d, delay_count_q;
    logic   [7:0]   shift_reg_q, shift_reg_d;
    logic   [2:0]   count_clk;
    logic           sample_en;
    logic   [7:0]   bit_matches;
    logic   [3:0]   match_count;
    logic           pattern_hit;

    /*
        LÓGICA DA VALIDAÇÃO DO DADO RECEBIDO

        Se tiver 6bit ou mais corretos, valida dado durante pulso de amostragem:
    */ 

    // analisa bit a bit e retorna 1 para os bits iguais:
    assign bit_matches = ~(shift_reg_d ^ padrao);

    // conta quantos sinais iguais teve:
    always_comb begin
        match_count = 4'd0;
        for (int i = 0; i < 8; i++) begin
            match_count = match_count + {3'd0, bit_matches[i]};
        end
    end

    // Validação ocorre somente no pulso do "sample_en":
    assign pattern_hit = sample_en && (match_count > 4'd6);


    // BLOCO SEQUENCIAL - Sincroniza com o relógio:
    always_ff @( posedge clk ) begin
        if (reset) begin                // Reset Global
            count_clk       <=  3'd0;   // Zera contagem de clock
            shift_reg_q     <=  8'd0;   // Limpa registrador do dado lido
            encontrado      <=  1'b0;   
            delay_count_q   <=  10'd0;  // zera contagem de atraso
            atraso          <=  10'd0;  // Limpa sinal de saída do atraso
        end
        else begin
            count_clk       <=  count_clk + 3'd1;
            encontrado      <=  1'b0;
            shift_reg_q     <=  shift_reg_d;
            if (sample_en) begin
                delay_count_q   <=  delay_count_d;

                if (pattern_hit) begin
                    encontrado      <=  1'b1;
                    atraso          <=  delay_count_d;
                    delay_count_q   <=  10'd0;
                end
            end
        end
    end

    // BLOCO COMBINACIONAL:
    always_comb begin
        sample_en       = 1'b0;
        shift_reg_d     = shift_reg_q;
        delay_count_d   = delay_count_q;

        // Pulso de amostragem a cada 8 ciclos (alinhado ao centro da janela de 8 ciclos)
        if (count_clk == 3'd4) begin
            sample_en = 1'b1;
        end

        // Lógica que atualiza registrador de deslocamento e a contagem de atraso:
        if (sample_en) begin
            shift_reg_d = {shift_reg_q[6:0], di};
            delay_count_d = delay_count_q + 10'd1;
        end
    end
endmodule
