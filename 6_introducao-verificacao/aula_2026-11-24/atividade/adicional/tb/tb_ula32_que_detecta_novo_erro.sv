
`timescale 1ns/1ps

module tb_ula32;

    // Sinais de entrada
    logic [31:0] A;
    logic [31:0] B;
    logic [2:0] OP;

    // Sinais de saída
    logic [31:0] RESULT;
    logic Z, N, C, V;

    // Contadores de testes
    int total = 0;
    int passed = 0;
    int failed = 0;

    // Instanciação do DUT
    ula32 dut (
        .A(A),
        .B(B),
        .OP(OP),
        .RESULT(RESULT),
        .Z(Z),
        .N(N),
        .C(C),
        .V(V)
    );

    // Task para aplicação e verificação dos testes
    task automatic check(
        input string test_name,
        input logic [2:0] op_test,
        input logic [31:0] a_test,
        input logic [31:0] b_test,
        input logic [31:0] expected_result,
        input logic expected_Z,
        input logic expected_N,
        input logic expected_C,
        input logic expected_V
    );

        // Aplicação dos estímulos
        A  = a_test;
        B  = b_test;
        OP = op_test;

        // Aguarda estabilização das saídas
        #10;

        total++;

        // Comparação automática
        if ((RESULT === expected_result) &&
            (Z === expected_Z) &&
            (N === expected_N) &&
            (C === expected_C) &&
            (V === expected_V)) begin

            passed++;

            $display("[PASS] %s", test_name);

        end
        else begin

            failed++;

            $display("[FAIL] %s", test_name);

            $display("A=%h B=%h OP=%b", A, B, OP);

            $display("RESULT obtido   = %h", RESULT);
            $display("RESULT esperado = %h",
                     expected_result);

            $display("Flags obtidas   = %b%b%b%b",
                     Z, N, C, V);

            $display("Flags esperadas = %b%b%b%b",
                     expected_Z, expected_N,
                     expected_C, expected_V);

        end

    endtask

    initial begin

        // Geração do arquivo de formas de onda
        $dumpfile("ula32.vcd");
        $dumpvars(0, tb_ula32);

        $display("INICIO DA VERIFICACAO");

        // ==================================
        // Testes da operação ADD
        // ==================================

        check("CT01 - ADD normal",
              3'b000,
              32'h00000005, 32'h00000003,
              32'h00000008, 0, 0, 0, 0);

        check("CT02 - ADD com carry",
              3'b000,
              32'hFFFFFFFF, 32'h00000001,
              32'h00000000, 1, 0, 1, 0);

        check("CT03 - ADD overflow positivo",
              3'b000,
              32'h7FFFFFFF, 32'h00000001,
              32'h80000000, 0, 1, 0, 1);

        check("CT04 - ADD overflow negativo",
              3'b000,
              32'h80000000, 32'h80000000,
              32'h00000000, 1, 0, 1, 1);

        // ==================================
        // Testes da operação SUB
        // ==================================

        check("CT05 - SUB resultado positivo",
              3'b001,
              32'h00000008, 32'h00000003,
              32'h00000005, 0, 0, 1, 0);

        check("CT06 - SUB resultado negativo",
              3'b001,
              32'h00000003, 32'h00000005,
              32'hFFFFFFFE, 0, 1, 0, 0);

        check("CT07 - SUB resultado zero",
              3'b001,
              32'h00000005, 32'h00000005,
              32'h00000000, 1, 0, 1, 0);

        check("CT08 - SUB com overflow",
              3'b001,
              32'h80000000, 32'h00000001,
              32'h7FFFFFFF, 0, 0, 1, 1);

        // ==================================
        // Testes das operações lógicas
        // ==================================

        check("CT09 - AND",
              3'b010,
              32'hAAAAAAAA, 32'h55555555,
              32'h00000000, 1, 0, 0, 0);

        check("CT10 - OR",
              3'b011,
              32'hAAAAAAAA, 32'h55555555,
              32'hFFFFFFFF, 0, 1, 0, 0);

        check("CT11 - XOR",
              3'b100,
              32'hFFFFFFFF, 32'hFFFFFFFF,
              32'h00000000, 1, 0, 0, 0);

        check("CT12 - NOT",
              3'b101,
              32'h00000000, 32'h00000000,
              32'hFFFFFFFF, 0, 1, 0, 0);

        // ==================================
        // Testes das operações de deslocamento
        // ==================================

        check("CT13 - SLL",
              3'b110,
              32'h00000001, 32'h00000004,
              32'h00000010, 0, 0, 0, 0);

        check("CT14 - SRL",
              3'b111,
              32'h80000000, 32'h00000004,
              32'h08000000, 0, 0, 0, 0);

        check("CT15 - SLL 31 posicoes",
              3'b110,
              32'h00000001, 32'h0000001F,
              32'h80000000, 0, 1, 0, 0);

        check("CT16 - SRL 31 posicoes",
              3'b111,
              32'h80000000, 32'h0000001F,
              32'h00000001, 0, 0, 0, 0);

        check("CT17 - SLL zero posicoes",
              3'b110,
              32'h12345678, 32'h00000000,
              32'h12345678, 0, 0, 0, 0);

        check("CT18 - SRL zero posicoes",
              3'b111,
              32'h12345678, 32'h00000000,
              32'h12345678, 0, 0, 0, 0);

        
        // ==================================
        // Teste ADICIONAL - ERRO DE ESCOPO
        // ==================================
        
        // Detecta erro proposital adicionado no RTL:
        //   - Nas operações SLL e SRL, o shift está considerando
        //     os 32 bits
        //
        // Usando B = 0x00000020, esperava-se que não houvesse deslocamento
        // pois 0x20 = 0b0010_0000, que sai do escopo de 5 bits, do projeto.
        check("CT19 - SLL 32 posicoes",
              3'b110,
              32'h00000001, 32'h00000020,
              32'h00000001, 0, 0, 0, 0);    

        check("CT20 - SRL 32 posicoes",
              3'b111,
              32'h80000000, 32'h00000020,
              32'h80000000, 0, 1, 0, 0);

        // ==================================
        // Relatório final
        // ==================================

        $display("--------------------------------");
        $display("RELATORIO FINAL");
        $display("Total de testes : %0d", total);
        $display("Testes aprovados: %0d", passed);
        $display("Testes reprovados: %0d", failed);
        $display("--------------------------------");

        if (failed == 0)
            $display("VERIFICACAO APROVADA");
        else
            $fatal(1, "VERIFICACAO REPROVADA");

        $finish;

    end

endmodule
