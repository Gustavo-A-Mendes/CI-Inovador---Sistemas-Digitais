`timescale 1ns/1ps

module delayed_ula_neander (
    input  logic [7:0] AC, RDM,
    input  logic [2:0] sel_ula,
    output logic [7:0] resultado_atrasado,
    output logic       N_atrasado, Z_atrasado
);
    logic [7:0] res_ideal;
    logic n_ideal, z_ideal;

    // Instancia o silício perfeito (sem atrasos)
    ula_neander ULA_REAL (
        .*,
        .resultado(res_ideal), 
        .N(n_ideal), 
        .Z(z_ideal)
    );

    // Injeta um atraso lógico artificial de 5 unidades de tempo
    // O Sintetizador profissional gritaria de ódio, mas o Icarus Verilog aceita.
    assign #5 resultado_atrasado = res_ideal;
    assign #5 N_atrasado = n_ideal;
    assign #5 Z_atrasado = z_ideal;

endmodule