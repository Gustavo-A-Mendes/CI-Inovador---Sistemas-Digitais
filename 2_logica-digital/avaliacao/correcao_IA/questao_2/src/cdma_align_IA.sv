module cdma_align_IA (
    input  logic       clk,
    input  logic       reset,
    input  logic       di,
    input  logic [7:0] padrao,
    output logic       encontrado,
    output logic [9:0] atraso
);

    logic [2:0] clk_cnt_q;
    /* verilator lint_off UNUSEDSIGNAL */
    logic [7:0] shift_reg_q;
    /* verilator lint_on UNUSEDSIGNAL */
    logic [9:0] bit_cnt_q;
    logic [3:0] valid_bits_q;

    logic       sample_en;
    logic [7:0] shift_reg_d;
    logic [7:0] bit_matches;
    logic [3:0] match_count;
    logic       pattern_hit;

    // Pulso de amostragem a cada 8 ciclos (alinhado ao centro da janela de 8 ciclos)
    assign sample_en = (clk_cnt_q == 3'd3);

    // Próximo estado do registrador de deslocamento (MSB-first)
    assign shift_reg_d = {shift_reg_q[6:0], di};

    // Comparação bit a bit (1 = bit igual ao padrão)
    assign bit_matches = ~(shift_reg_d ^ padrao);

    // Soma combinacional da quantidade de bits coincidentes (0 a 8)
    always_comb begin
        match_count = 4'd0;
        for (int i = 0; i < 8; i++) begin
            match_count = match_count + {3'd0, bit_matches[i]};
        end
    end

    // Padrão válido apenas após acumular pelo menos 8 bits desde o reset/última detecção
    // e com mais de 6 bits corretos (7 ou 8 bits iguais)
    assign pattern_hit = sample_en && (valid_bits_q >= 4'd7) && (match_count > 4'd6);

    always_ff @(posedge clk) begin
        if (reset) begin
            clk_cnt_q    <= 3'd0;
            shift_reg_q  <= 8'd0;
            bit_cnt_q    <= 10'd0;
            valid_bits_q <= 4'd0;
            encontrado   <= 1'b0;
            atraso       <= 10'd0;
        end else begin
            // Contador de 8 ciclos por bit
            clk_cnt_q <= clk_cnt_q + 3'd1;

            // Pulso de 1 ciclo por padrão
            encontrado <= 1'b0;

            if (sample_en) begin
                shift_reg_q <= shift_reg_d;

                if (pattern_hit) begin
                    encontrado   <= 1'b1;
                    atraso       <= bit_cnt_q + 10'd1;
                    bit_cnt_q    <= 10'd0;
                    valid_bits_q <= 4'd0;
                end else begin
                    // Incrementa e zera automaticamente no overflow de 10 bits (1023 -> 0)
                    bit_cnt_q <= bit_cnt_q + 10'd1;
                    if (valid_bits_q < 4'd8) begin
                        valid_bits_q <= valid_bits_q + 4'd1;
                    end
                end
            end
        end
    end

endmodule
