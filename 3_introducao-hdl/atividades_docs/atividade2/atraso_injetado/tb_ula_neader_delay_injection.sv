`timescale 1ns / 1ps // Fundamental para simulação de timing (Resolução)

module tb_top_level;

    parameter MAX_SIZE = 100;

    // 1. Sinais de Testbench
    // Sinais de estímulo
    logic [7:0] AC, RDM;
    logic [2:0] sel_ula;

    // Sinais de saída (Design Ideal)
    logic [7:0] res;
    logic n, z;

    logic [18:0] test_values [0:MAX_SIZE-1];

    // 2. Instanciação da Netlist Pós-Implementação (Design Under Test)
    // Este módulo não é mais o seu RTL limpo, mas a netlist gerada pelo Vivado.
    ula_neander DUT (
        .AC(AC), .RDM(RDM), .sel_ula(sel_ula),
        .resultado(res), .N(n), .Z(z)
    );

    // 3. Injeção Manual do Atraso Físico (SDF Annotation)
    initial begin
        // A task $sdf_annotate lê o arquivo gerado pelo P&R e aplica 
        // os atrasos na instância 'DUT'.
        // Argumentos: ("nome_do_arquivo.sdf", instancia_alvo, config_logs, ...)
        // $sdf_annotate("meu_projeto_atrasos.sdf", tb_top_level.DUT, , "sdf_log.txt");
        $sdf_annotate("meu_projeto_atrasos.sdf", tb_top_level.DUT, , "sdf_log.txt", "MINIMUM");
    end

    // Gera arquivo dump, com os sinais do testbench e o design top_level:
    initial begin
        $dumpfile("tb_ULA_neander.vcd");
        $dumpvars;
    end
    // initial begin
    //     tb_AC = 8'd10; tb_RDM = 8'd14; tb_sel = 3'b000;
    //     #50;
    //     tb_sel = 3'b001;
    //     #50;
    //     $finish;
    // end

    initial begin
        AC = 8'h00; RDM = 8'h00; sel_ula = 3'b001;
        
        // inicialização da memória:
        for (int i = 0; i < MAX_SIZE; i++) 
            test_values[i] = 19'bx;
        
        #10;

        // Leitura dos valores de estímulos das entradas:
        $readmemb("input_values.mem", test_values);
        
        for (int i = 0; (i < MAX_SIZE) && (test_values[i] !== 19'bx); i++) begin
            AC = test_values[i][18:11]; RDM = test_values[i][10:3]; sel_ula = test_values[i][2:0];
            
            #10;
            
//            $display("%tns \tAC = %b (%d) \tRDM = %b (%d) \tsel_ula = %b \tresultado = %b (%d) \t Z = %b \tN = %b", $realtime, AC, AC, RDM, RDM, sel_ula, resultado, resultado, Z, N);
        end
        
        $finish; 
    end
endmodule