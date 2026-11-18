`timescale 1ns/1ps

module rdm (
    input   logic           clk_i,
    input   logic           rst_n_i,    // Reset global

    input   logic   [7:0]   rdm_ac_i,   // Entrada do registrador
    input   logic   [7:0]   rdm_mem_i,  // Entrada vinda da memória

    input   logic           sel_i,      // Seleciona entrada. 0 -> MEM; 1 -> AC
    input   logic           load_i,     // Habilita carga RDM

    output  logic   [7:0]   rdm_q       // Saída do registrador
);

    // Mulplexador na entrada do RDM:
    logic [7:0] rdm_d;
    assign rdm_d = (sel_i) ?  rdm_ac_i : rdm_mem_i;

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)       rdm_q <= 8'h00;     // Reset global
        else if (load_i)    rdm_q <= rdm_d;  // Carga de AC 
    end
endmodule