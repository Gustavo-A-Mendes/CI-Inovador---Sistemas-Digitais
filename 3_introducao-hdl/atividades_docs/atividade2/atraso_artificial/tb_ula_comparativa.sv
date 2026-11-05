`timescale 1ns/1ps

module tb_ula_comparativa;
    // parameter MAX_SIZE = 100;

    // Sinais de estímulo
    logic [7:0] tb_AC, tb_RDM;
    logic [2:0] tb_sel;

    // Sinais de saída (Design Ideal)
    logic [7:0] res_ideal;
    logic n_ideal, z_ideal;

    // Sinais de saída (Design com Atraso Artificial)
    logic [7:0] res_atrasado;
    logic n_atrasado, z_atrasado;
    
    // logic [18:0] test_values [0:MAX_SIZE-1];

    // 1. Instancia o Silício Ideal
    ula_neander DUT_IDEAL (
        .AC(tb_AC), .RDM(tb_RDM), .sel_ula(tb_sel),
        .resultado(res_ideal), .N(n_ideal), .Z(z_ideal)
    );

    // 2. Instancia o Wrapper com Atraso
    delayed_ula_neander DUT_ATRASADO (
        .AC(tb_AC), .RDM(tb_RDM), .sel_ula(tb_sel),
        .resultado_atrasado(res_atrasado), .N_atrasado(n_atrasado), .Z_atrasado(z_atrasado)
    );

    // Geração de Estímulos
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_ula_comparativa);
        
        tb_AC = 8'd10; tb_RDM = 8'd15; tb_sel = 3'b000; // ADD
        
        // No visualizador de ondas (EPWave), você verá 'res_ideal' 
        // mudar no tempo 0, e 'res_atrasado' mudar no tempo 5.
        #20 $finish; 
    end

endmodule