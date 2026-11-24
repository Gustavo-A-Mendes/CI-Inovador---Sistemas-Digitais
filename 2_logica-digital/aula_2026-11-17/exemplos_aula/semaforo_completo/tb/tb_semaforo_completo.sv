`timescale 1ns/1ps

module tb_semaforo_completo;

    logic           clk_tb, reset_tb, pedestre_tb;
    logic   [2:0]   sinal_rua1_tb, sinal_rua2_tb;
    logic   [1:0]   sinal_pedestre_tb;

    semaforo_completo sf(
        .clk(clk_tb),
        .reset(reset_tb),
        .pedestre(pedestre_tb),
        .sinal_rua1(sinal_rua1_tb),
        .sinal_rua2(sinal_rua2_tb),
        .sinal_pedestre(sinal_pedestre_tb)
    );

    
    initial begin
        clk_tb = 1'b0;
        forever begin
            #5 clk_tb = ~clk_tb;
        end
    end

    initial begin
        $dumpfile("teste.vcd");
        $dumpvars;
        
        $sdf_annotate("../src/atrasos_meu_design.sdf", tb_semaforo_completo.sf, , "sdf_log.txt", "MAXIMUM");

        reset_tb = 1'b1;       // sinal reset inicia "ligado" (no sinal de ativação dele, seja 1 ou 0) (boa prática)
        pedestre_tb = 1'b0;    // sinal de pedestre inicia desligado
        @(posedge clk_tb);

        reset_tb = 1'b0;
        ##70;

        pedestre_tb = 1'b1; // Acionado por 1s
        ##1;

        pedestre_tb = 1'b0; 
        ##20;

        $finish;
    end
endmodule