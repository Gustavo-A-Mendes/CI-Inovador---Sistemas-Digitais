`timescale 1ns / 1ps

module tb_top_level;

    // 1. Sinais
    logic [7:0] tb_AC, tb_RDM;
    logic [2:0] tb_sel;
    logic [7:0] tb_res;
    logic       tb_n, tb_z;

    // 2. Instanciação do Design (DUT)
    ula_neander DUT (
        .AC(tb_AC), .RDM(tb_RDM), .sel_ula(tb_sel),
        .resultado(tb_res), .N(tb_n), .Z(tb_z)
    );

    // ---------------------------------------------------------
    // MÓDULO DE VERIFICAÇÃO AVANÇADA (GLS TIMING AWARENESS)
    // Padrão IEEE 1800 - SystemVerilog Assertions (SVA)
    // ---------------------------------------------------------

    // 1. Relógio de Amostragem (Oversampling) exclusivo para a Verificação
    // Gera um pulso a cada 1ns (Resolução da régua do SVA)
    logic clk_sva = 1'b0;
    always #0.5ns clk_sva = ~clk_sva; 

    // 2. Tradução do limite de PPA Analógico para Ciclos Discretos
    // Queremos que o Caminho Crítico morra em no máximo 8ns
    localparam int MAX_PROP_CYCLES = 8; 

    // 3. Máquina de Estados da Propriedade Concorrente
    property p_ula_estabilizacao_segura;
        // O motor SVA agora possui a referência de tempo necessária
        @(posedge clk_sva) 
        
        // GATILHO: A função nativa $changed compara o valor atual com o do ciclo anterior
        $changed({tb_AC, tb_RDM, tb_sel}) 
        
        // IMPLICAÇÃO (Se o gatilho for verdadeiro, inicie a contagem)
        |-> 
        
        // VERIFICAÇÃO: Após exatos 8 ciclos (8ns), garante que não há mais glitches rodando.
        // A função nativa $stable garante que a saída atual é igual à do instante 7ns.
        ##MAX_PROP_CYCLES $stable({tb_res, tb_n, tb_z});
    endproperty

    // 4. Bind da Asserção na simulação
    assert_timing_fisico: assert property (p_ula_estabilizacao_segura)
        else $error("FALHA DE PPA: O atraso físico (SDF) excedeu a margem de 8ns estipulada pela Arquitetura!");

    // 5. Geração de Estímulos e Injeção SDF (Omitidos para brevidade)
    // 3. Injeção Manual do Atraso Físico (SDF Annotation)
    initial begin
        // A task $sdf_annotate lê o arquivo gerado pelo P&R e aplica 
        // os atrasos na instância 'DUT'.
        // Argumentos: ("nome_do_arquivo.sdf", instancia_alvo, config_logs, ...)
        $sdf_annotate("meu_projeto_atrasos.sdf", tb_top_level.DUT, , "sdf_log.txt", "MAXIMUM");
    end

    initial begin
        tb_AC = 8'd10; tb_RDM = 8'd15; tb_sel = 3'b000;
        #50;
        tb_sel = 3'b001;
        #50;
        $finish;
    end

endmodule