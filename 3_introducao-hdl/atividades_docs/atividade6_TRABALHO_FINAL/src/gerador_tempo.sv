`timescale 1ns/1ps

module gerador_tempo (
    input   logic           clk_i,
    input   logic           rst_n_i,    // Reset global
    input   logic           goto_t0_i,  // Sinal de controle
    output  logic   [7:0]   t_q         // Vetor One-Hot de tempos (t0 a t7)
    output  logic   [2:0]   t_num_o       // Vetor One-Hot de tempos (t0 a t7)
);

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        t_q <= 8'b0000_0001; t_num_o <= 3'd0;

        if (!rst_n_i) begin       
            t_q <= 8'b0000_0001;    // Reset global: força tempo para t0
            t_num_o <= 3'd0;
        end
        else if (goto_t0_i) begin
            t_q <= 8'b0000_0001;    // Retorno ao t0
            t_num_o <= 3'd0;
        end
        else begin 
            if (t_q[7]) begin
                t_q <= 8'b0000_0001;    // Se 1 estiver no final (t7), move o 1 de volta para o início (t0), 
                t_num_o <= 3'd0;
            end
            else begin
                t_q <= t_q << 1;    // desloca para direita
                t_num_o <= t_num_o + 1'd1;
            end
        end
    end
endmodule