`timescale 1ns/1ps

module tb();

    // Declaração de sinais
    logic       clk;
    logic       reset;
    logic       botao_pedestre;
    logic [4:0] Q;

    // Instanciação do DUT (Device Under Test)
    semaforo_pedestre dut (
        .clk(clk),
        .reset(reset),
        .botao_pedestre(botao_pedestre),
        .Q(Q)
    );

    // Geração de Clock (Período de 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Geração de Estímulos
    initial begin
        // Inicialização
        reset = 1;
        botao_pedestre = 0;
        
        // Aguarda alguns ciclos e desativa o reset
        #20;
        reset = 0;

        // Aguarda no estado S0 (verde para carros, vermelho para pedestres)
        #30;

        // Pedestre aperta o botão
        @(negedge clk) botao_pedestre = 1;
        @(negedge clk) botao_pedestre = 0; // Solta o botão

        // Aguarda a transição dos estados (S1 durará 2 ciclos, S2 durará 4 ciclos)
        // Damos um tempo de sobra para ver o ciclo completo voltar ao S0
        #100;

        // Fim da simulação
        $finish;
    end

    // Monitoramento no terminal
    initial begin
        $monitor("Tempo: %0t | Reset: %b | Botao: %b | Estado Interno: %b | Q (Saidas): %b | Count: %d", 
                 $time, reset, botao_pedestre, dut.curr_state, Q, dut.count);
    end

    // Geração de arquivo de forma de onda (VCD)
    initial begin
        $dumpfile("semaforo.vcd");
        $dumpvars(0, tb);
    end

endmodule