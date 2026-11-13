module rdm (
    input   logic           clk_i,
    input   logic           rst_n_i,    // Reset global
    input   logic   [7:0]   rdm_d,      // Entrada do registrador
    input   logic   [7:0]   rdm_mem_i,  // Entrada vinda da memória
    input   logic           load_i,     // Habilita carga RDM <- AC
    input   logic           write_i,    // Habilita escrita na memória [ MEM(end) <- RDM ]
    input   logic           read_i,     // Habilita leitura da memória [ RDM <- MEM(end) ]
    output  logic   [7:0]   rdm_q,      // Saída do registrador para AC|RI|REM|PC|Y
    // output  logic   [7:0]   rdm_mem_q,  // Saída do registrador para memória
);

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)       rdm_q <= 8'h00;     // Reset global
        else if (load_i)    rdm_q <= rdm_d;     // Carga de AC
        
        else if (read_i)    rdm_q <= rdm_mem_i; // Leitura da memória 
        // else if (read_i)    rdm_mem_q <= rdm_mem_i; // Leitura da memória 
    end
endmodule