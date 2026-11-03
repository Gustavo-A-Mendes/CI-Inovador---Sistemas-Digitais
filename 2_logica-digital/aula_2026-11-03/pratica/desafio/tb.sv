`timescale 1ns/1ps

module tb;

  // Sinais de interface do MUX
  logic       EN;
  logic [2:0] A;
  logic [7:0] X;
  logic       Q;

  // Instância do Módulo Sob Teste (DUT)
  meu_primeiro_mux8x1 dut (
    .EN (EN),
    .A  (A),
    .X  (X),
    .Q  (Q)
  );

  initial begin
    // Inicialização dos sinais
    EN = 1'b1;
    A  = 3'b000;
    
    // Vetor de teste: X[7:0] = 8'b1010_1100
    // X[0]=0, X[1]=0, X[2]=1, X[3]=1, X[4]=0, X[5]=1, X[6]=0, X[7]=1
    X  = 8'b1010_1100;

    $display("=== INÍCIO DO TESTE DO MUX 8x1 ===");
    #10;

    // Varre todas as 8 seleções de entrada (0 a 7)
    for (int i = 0; i < 8; i++) begin
      A = i;
      #10; // Aguarda 10ns para propagação dos sinais
      
      // Validação visual e automática no console
      if (Q === X[i]) begin
        $display("[PASS] Seleção A = %3b (%0d) | Saída Q = %b | Esperado X[%0d] = %b", 
                 A, A, Q, i, X[i]);
      end else begin
        $display("[FAIL] Seleção A = %3b (%0d) | Saída Q = %b | Esperado X[%0d] = %b", 
                 A, A, Q, i, X[i]);
      end
    end

    // Teste adicional: alterando o vetor de entradas dinamicamente
    #10;
    $display("\n=== TESTE COM VETOR DINÂMICO ===");
    X = 8'b1111_0000; // Metade superior 1, metade inferior 0
    
    A = 3'b001; // Deve selecionar X[1] = 0
    #10;
    $display("Seleção A = %3b | Saída Q = %b (Esperado: 0)", A, Q);

    A = 3'b110; // Deve selecionar X[6] = 1
    #10;
    $display("Seleção A = %3b | Saída Q = %b (Esperado: 1)", A, Q);

    $display("\nSimulação finalizada com sucesso!");
    $finish;
  end

  // Geração do arquivo VCD para análise de ondas no GTKWave / EDA Playground
  initial begin
    $dumpfile("meu_primeiro_mux8x1_tb.vcd");
    $dumpvars(0, tb);
  end

endmodule