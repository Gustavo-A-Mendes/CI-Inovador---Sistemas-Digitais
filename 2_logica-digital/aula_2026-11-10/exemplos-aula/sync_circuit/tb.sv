`timescale 1ns / 1ps

module tb_design;

    // Sinais para conectar ao módulo
    logic clk;
    logic reset;
    logic [4:0] valor_maximo;
    logic [4:0] Q;
    logic fim;

    // Instanciação do Device Under Test (DUT)
    design dut (
        .clk(clk),
        .reset(reset),
        .valor_maximo(valor_maximo),
        .Q(Q),
        .fim(fim)
    );

    // Geração de Clock (Período = 10ns)
    always #5 clk = ~clk;

    // Estímulos
    initial begin
        // Configuração inicial para o gerador de formas de onda (opcional)
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_design);

        // Estado inicial
        clk = 0;
        reset = 1;
        valor_maximo = 5'd5;

        // Libera o reset após 15ns
        #15 reset = 0;

        // Deixa o contador rodar até ultrapassar o valor máximo (espera contar 0 a 5 e zerar)
        #80;

        // Altera o valor máximo para testar o comportamento dinâmico
        valor_maximo = 5'd10;
        
        // Deixa contar com o novo limite
        #150;

        // Testa o reset assíncrono no meio da contagem
        reset = 1;
        #10 reset = 0;

        // Deixa contar mais um pouco
        #50;

        // Encerra a simulação
        $finish;
    end

    // Monitoramento no console
    initial begin
        $monitor("Tempo: %0t | reset: %b | max: %2d | Q: %2d | fim: %b", 
                 $time, reset, valor_maximo, Q, fim);
    end

endmodule