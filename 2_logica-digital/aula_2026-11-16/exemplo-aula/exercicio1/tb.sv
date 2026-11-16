`timescale 1ns/1ps

module tb();

    // Sinais do testbench
    logic       clk;
    logic       reset;
    logic [2:0] Q1;
    logic [2:0] Q2;

    // Instanciação do DUT (Device Under Test)
    semaforo_pedestre dut (
        .clk(clk),
        .reset(reset),
        .Q1(Q1),
        .Q2(Q2)
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
        
        // Aguarda 2 ciclos de clock e desativa o reset
        #20;
        reset = 0;

        // Como o semáforo agora é automático e não depende do botão,
        // vamos simplesmente deixá-lo rodar por tempo suficiente para 
        // observar o ciclo completo: S0 -> S1 -> S2 -> S1 -> S0
        // (S0 leva 4 ciclos, S1 leva 1 ciclo, S2 leva 4 ciclos)
        
        #250;

        // Encerra a simulação
        $finish;
    end

    // Monitoramento no terminal
    initial begin
        $monitor("Tempo: %0t | rst: %b | Estado: %b | count: %d | sinal: %b | Q1: %b | Q2: %b", 
                 $time, reset, dut.curr_state, dut.count, dut.sinal, Q1, Q2);
    end

    // Geração do arquivo VCD para visualização de ondas
    initial begin
        $dumpfile("semaforo.vcd");
        $dumpvars(0, tb);
    end

endmodule