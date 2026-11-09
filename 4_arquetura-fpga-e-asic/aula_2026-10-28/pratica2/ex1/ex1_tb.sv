`timescale 1ns/1ps

module LUT2_tb;

  // Sinais de entrada e saídas
  logic A, B, C, D, O_ori, O_simp;
  logic [0:15] O_ori_mem, O_simp_mem;

  // Memória para os vetores de teste (16 posições de 4 bits)
  logic [3:0] memory [0:15];

  // Variáveis de controle do teste
  int i;
  int error_count = 0;

  // Instâncias dos módulos sob teste (DUTs)
  LUT2_circuit_original lutORI(.*);
  LUT2_circuit_simplified lutSIMP(.*);

  initial begin
    // 1. Carrega os valores do arquivo na memória
    $readmemb("input_values.txt", memory);

    $display("--------------------------------------------");
    $display("Iniciando Verificação de Equivalência Logica");
    $display("--------------------------------------------");
	
    $display("                Tempo            Entradas LUT                 Saídas");
      $display("                   \t A\t B\t C\t D\tO_simp |  O_ori");
      $display("                =====   ===========================   ====================");
    $monitor($time," \t %b \t %b \t %b \t %b \t   %b   |    %b", A, B, C, D, O_simp, O_ori);
    
    // 2. Loop de aplicação de estimulos
    for (i = 0; i < 16; i++) begin
      // Atribuição das entradas a partir do vetor lido
      A = memory[i][3]; B = memory[i][2]; C = memory[i][1]; D = memory[i][0];

      O_ori_mem[i]  = O_ori;
      O_simp_mem[i] = O_simp;

      // Aguarda a propagação dos sinais nos circuitos combinacionais
      #5;
    end

    // 3. Comparação entre a saída original e a simplificada (esperada)
    for (i = 0; i< 16; i++) begin
      if (O_ori_mem[i] !== O_simp_mem[i]) begin
        $display("[ERRO] Vetor %0d (ABCD=%b%b%b%b): Obtido (O_ori) = %b | Esperado (O_simp) = %b", 
                 i, A, B, C, D, O_ori_mem[i], O_simp_mem[i]);
        error_count++;
      end
    end

    // 4. Relatório final
    $display("--------------------------------------------");
    if (error_count == 0) begin
      $display("SUCESSO: Todos os 16 testes passaram sem erros!");
    end else begin
      $display("FALHA: Teste finalizado com %0d erro(s).", error_count);
    end
    $display("--------------------------------------------");

    $finish;
  end
endmodule