module gerador_tempo (
    input   logic           clk_i,
    input   logic           rst_n_i,    // Reset global
    input   logic           goto_t0_i,  // Sinal de controle
    output  logic   [7:0]   t_o         // Vetor One-Hot de tempos (t0 a t7)
);

    always_ff @( posedge clk or negedge rst_n_i ) begin
        if (!rst_n_i)       t_o <= 8'b0000_0001;    // Reset global: força tempo para t0
        else if (goto_t0_i) t_o <= 8'b0000_0001;    // Retorno ao t0
        else begin 
            if (t_o[7])     t_o <= 8'b0000_0001;    // Se 1 estiver no final (t7), move o 1 de volta para o início (t0), 
            else            t_o <= t_o << 1;    // desloca para direita
        end
    end
endmodule