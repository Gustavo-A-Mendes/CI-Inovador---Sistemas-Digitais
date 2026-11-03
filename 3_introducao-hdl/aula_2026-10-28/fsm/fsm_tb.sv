`timescale 1ns / 1ps

module tb_moduleName;

  // Sinais de teste
  reg clk;
  reg rst;
  reg in_A;
  wire out_D;

  // Instância do Módulo sob Teste (DUT - Device Under Test)
  moduleName dut (
    .clk(clk),
    .rst(rst),
    .in_A(in_A),
    .out_D(out_D)
  );

  // Geração do Clock (Período de 10ns = 100MHz)
  always #5 clk = ~clk;

  // Bloco Principal de Testes
  initial begin
    // Inicialização dos sinais
    clk = 0;
    rst = 1;
    in_A = 0;

    // Monitoramento no console
    $monitor("Tempo: %0t | rst: %b | in_A: %b | out_D: %b | Estado Interno: %0d", 
             $time, rst, in_A, out_D, dut.state);

    // Libera o reset após 15ns
    #15;
    rst = 0;
    #5;

    // --- Teste 1: Sequência correta para atingir S4 e ativar out_D (1 -> 1 -> 0 -> 1) ---
    // Transição: S0 -> S1
    in_A = 1; #10;
    
    // Transição: S1 -> S2
    in_A = 1; #10;
    
    // Transição: S2 -> S3
    in_A = 0; #10;
    
    // Transição: S3 -> S4 (out_D deve ir para 1)
    in_A = 1; #10;

    // --- Teste 2: Saída do estado S4 ---
    // Transição: S4 -> S0 (com in_A = 0)
    in_A = 0; #10;

    // --- Teste 3: Sequência errada (retorno ao estado inicial) ---
    in_A = 1; #10; // S0 -> S1
    in_A = 0; #10; // S1 -> S0 (reset de sequência via entrada 0)

    // --- Teste 4: Permanência no estado S2 com múltiplos 1s ---
    in_A = 1; #10; // S0 -> S1
    in_A = 1; #10; // S1 -> S2
    in_A = 1; #10; // Permanecer em S2
    in_A = 1; #10; // Permanecer em S2
    in_A = 0; #10; // S2 -> S3
    in_A = 1; #10; // S3 -> S4 (out_D deve ir para 1 novamente)

    // Retorna ao estado inicial e encerra a simulação
    in_A = 0; #10;
    #20;

    $display("Simulação concluída!");
    $finish;
  end

endmodule