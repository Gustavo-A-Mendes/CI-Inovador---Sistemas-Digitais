module tb_ALU;
  
  logic [7:0] A, B, result;
  logic [2:0] opcode;
  logic zero, carry;

  // variáveis para leitura de input:
  parameter N = 100;
  logic [18:0] test_values [0:N-1];
  int i;

  ALU alu0(.*);

  initial begin
    $dumpfile("tb_ALU.vcd");
    $dumpvars(0, tb_ALU);

    // Inicialização da memória:
    for (i = 0; i < N; i++) begin
      test_values[i] = 19'bx;
    end

  end

  initial begin
    $readmemb("input_values.mem", test_values);

    for (i = 0; (i < N) && (test_values[i] !== 19'bx); i++) begin
      A = test_values[i][18:11]; B = test_values[i][10:3]; opcode = test_values[i][2:0];
      
      #5;

      $display("%tns \tA = %b (%d) \tB = %b (%d) \topcode = %b \tcarry = %b \tresult = %b (%d) \t zero = %b", $realtime, A, A, B, B, opcode, carry, result, result, zero);

    end

    $display("\n\nTeste Concluido!");
    $finish;
  end

endmodule