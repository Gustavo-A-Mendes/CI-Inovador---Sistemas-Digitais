`timescale 1ns/1ps

module tb();

    // Sinais do testbench
    logic clk;
    logic reset;
    logic x;
    logic match;

    // Instanciação do Device Under Test (DUT)
    circuito_sincrono dut (
        .clk(clk),
        .reset(reset),
        .x(x),
        .match(match)
    );

    // Geração do clock (Período de 10 unidades de tempo)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Geração de estímulos
    initial begin
        // Condições iniciais e Reset
        x = 0;
        reset = 1;
        
        // Aguarda dois ciclos de clock para liberar o reset
        #20;
        reset = 0;

        // O registrador faz shift-left: {dado_ff[2:0], x}
        // Para formar 4'b0111, precisamos inserir os bits na ordem: 0, 1, 1, 1
        
        // Inserindo '0'
        @(negedge clk) x = 0;
        
        // Inserindo '1'
        @(negedge clk) x = 1;
        
        // Inserindo '1'
        @(negedge clk) x = 1;
        
        // Inserindo '1' (após a borda de subida seguinte, match deve ir para 1)
        @(negedge clk) x = 1;
        
        // Mantém mais um ciclo para visualizar o match = 1
        @(negedge clk);
        
        // Inserindo '0' para quebrar a sequência (match deve voltar para 0)
        x = 0;
        @(negedge clk);
        
        // Inserindo bits aleatórios
        x = 1; @(negedge clk);
        x = 0; @(negedge clk);

        // Encerra a simulação
        #20;
        $finish;
    end

    // Monitoramento no terminal
    initial begin
        $monitor("Tempo: %0t | reset: %b | x: %b | dado_ff (interno): %b | match: %b", 
                 $time, reset, x, dut.dado_ff, match);
    end

    // Opcional: Geração de arquivo VCD para visualizar formas de onda (GTKWave/ModelSim)
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

endmodule