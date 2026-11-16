`timescale 1ns/1ps

module pc (
    input   logic           clk_i,
    input   logic           rst_n_i,    // Reset global
    input   logic           ld_pc_i,    // Habilita carga paralela
    input   logic           inc_pc_i,   // Habilita incremento
    input   logic   [7:0]   pc_d,       // Entrada paralela
    output  logic   [7:0]   pc_q        // Saída paralela do registrado
);

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)       pc_q <= 8'h00;          // Reset global
        else if (ld_pc_i)   pc_q <= pc_d;           // Carga paralela
        else if (inc_pc_i)  pc_q <= pc_q + 1'b1;    // Incremento
    end
endmodule