`timescale 1ns / 1ps // Fundamental para simulação de timing (Resolução)

module tb_top_level;

    // 1. Sinais de Testbench
    // Sinais de estímulo
    logic [7:0] tb_AC, tb_RDM;
    logic [2:0] tb_sel;

    // Sinais de saída (Design Ideal)
    logic [7:0] tb_res;
    logic tb_n, tb_z;

    // 2. Instanciação da Netlist Pós-Implementação (Design Under Test)
    // Este módulo não é mais o seu RTL limpo, mas a netlist gerada pelo Vivado.
    ula_neander DUT (
        .AC(tb_AC), .RDM(tb_RDM), .sel_ula(tb_sel),
        .resultado(tb_res), .N(tb_n), .Z(tb_z)
    );

    // 3. Injeção Manual do Atraso Físico (SDF Annotation)
    initial begin
        // A task $sdf_annotate lê o arquivo gerado pelo P&R e aplica 
        // os atrasos na instância 'DUT'.
        // Argumentos: ("nome_do_arquivo.sdf", instancia_alvo, config_logs, ...)
        $sdf_annotate("meu_projeto_atrasos.sdf", tb_top_level.DUT, , "sdf_log.txt");
        // $sdf_annotate("meu_projeto_atrasos.sdf", tb_top_level.DUT, , "sdf_log.txt", "MAXIMUM");
    end

    initial begin
        tb_AC = 8'd10; tb_RDM = 8'd15; tb_sel = 3'b000;
        #50;
        tb_sel = 3'b001;
        #50;
        $finish;
    end
endmodule