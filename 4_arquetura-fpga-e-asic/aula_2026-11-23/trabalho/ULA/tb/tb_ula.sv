`timescale 1ns/1ps

module tb_ula;

    logic [7:0] a_tb, b_tb, f_tb;
    logic [2:0] s_tb;
    logic       m_tb;
    
    int total_tests = 0;
    int error_count = 0;

    // Instânciando módulo DUT:
    ula dut(
        .a_i(a_tb),
        .b_i(b_tb),
        .m_i(m_tb),
        .s_i(s_tb),
        .f_o(f_tb)
    );

    // Automação dos textos de teste:
    string operacoes[8][2] = '{
        '{"A + B",      "NOT(A)"},
        '{"A - B",      "NOT(A OR B)"},
        '{"A * B",      "NOT(A AND B)"},
        '{"A / B",      "NOT(A XOR B)"},
        '{"A - 1",      "(A AND B)"},
        '{"B - 1",      "(A OR B)"},
        '{"A + NOT(B)", "(A XOR B)"},
        '{"NOT(A) + B", "NOT(B)"}
    };
    
    function automatic logic [7:0] calc_expected(
        input logic [7:0] a,
        input logic [7:0] b,
        input logic       m,
        input logic [2:0] s
    );
        logic [7:0] res;
        case (s)
            3'd0: res = m ? (~a)         : (a + b);
            3'd1: res = m ? (~(a | b))   : (a - b);
            3'd2: res = m ? (~(a & b))   : (a * b);
            3'd3: begin
                if (m)           res = ~(a ^ b);
                else if (b == 0) res = 8'hFF; // Regra de divisão por zero
                else             res = a / b;
            end
            3'd4: res = m ? (a & b)      : (a - 8'd1);
            3'd5: res = m ? (a | b)      : (b - 8'd1);
            3'd6: res = m ? (a ^ b)      : (a + ~b);
            3'd7: res = m ? (~b)         : (~a + b);
            default: res = 8'd0;
        endcase
        return res;
    endfunction

    task automatic verifica_resultado(input bit verbose = 1'b1);
        logic   [7:0]   expected_f;
        logic           only_opA, only_opB;

        // Tempo de estabilização:
        #50;

        expected_f = calc_expected(a_tb, b_tb, m_tb, s_tb);
        total_tests++;

        if (f_tb !== expected_f) begin
            error_count++;
            $error("\n[FAIL] OP=%1d (M=%1b: %s) | A=%3d (0x%02h), B=%3d (0x%02h) | Obtido=%3d (0x%02h) != Esperado=%3d (0x%02h)\n",
                   s_tb, m_tb, operacoes[s_tb][m_tb],
                   a_tb, a_tb, b_tb, b_tb,
                   f_tb, f_tb, expected_f, expected_f);
        end else if (verbose) begin

            // Exibe a operação sendo feita:
            $display("===== OPERACAO %1d: %s =====", s_tb, operacoes[s_tb][m_tb]);

            // Exibe operandos de interesse e o resultado
            only_opA = (( m_tb && (s_tb == 3'd0) ) || ( ~m_tb && (s_tb == 3'd4) ));
            only_opB = (( m_tb && (s_tb == 3'd7) ) || ( ~m_tb && (s_tb == 3'd5) ));

            if (only_opA) begin
                $display(">> A=%3d (%02h | %08b)\n>> F=%3d (%02h | %08b) [Exp: %02h]\n",
                         a_tb, a_tb, a_tb, f_tb, f_tb, f_tb, expected_f);
            end else if (only_opB) begin
                $display(">> B=%3d (%02h | %08b)\n>> F=%3d (%02h | %08b) [Exp: %02h]\n",
                         b_tb, b_tb, b_tb, f_tb, f_tb, f_tb, expected_f);
            end else begin
                $display(">> A=%3d (%02h | %08b)\n>> B=%3d (%02h | %08b)\n>> F=%3d (%02h | %08b) [Exp: %02h]\n",
                         a_tb, a_tb, a_tb, b_tb, b_tb, b_tb, f_tb, f_tb, f_tb, expected_f);
            end
        end
    endtask //automatic


    // Gerando Estímulos:
    initial begin
        $dumpfile("tb_ula.vcd");
        $dumpvars(0, tb_ula);

        // Inicializa sinais:
        a_tb = 8'd0; b_tb = 8'd0; s_tb = 3'd0; m_tb = 1'b0;
        #10;

        // ============================================================
        // Teste 01: Operadores Lógicos (M = 1)
        // ============================================================
        m_tb = 1'b1;
        
        a_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        b_tb = 8'd210;  // 8'b1101_0010; 8'hD2
        
        $display("\n===== TESTE 01: OPERADORES LOGICOS (M = 1) =====");

        for (int i = 0; i < 8; i++) begin
            s_tb = i[2:0];
            verifica_resultado();
        end        
        
        // ============================================================
        // Teste 02: Operadores Aritméticos (M = 1)
        // ============================================================
        m_tb = 1'b0;

        a_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        b_tb = 8'd210;  // 8'b1101_0010; 8'hD2
        
        $display("===== TESTE 02: OPERADORES ARITMETICOS (M = 0) =====");
        
        s_tb = 3'd0; // A + B
        
        $display("-- Soma sem overflow");
        a_tb = 8'd18;   // 8'b0001_0010; 8'h12
        b_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        verifica_resultado();
        #5;
        
        $display("-- Soma com overflow");
        a_tb = 8'd210;  // 8'b1101_0010; 8'hD2
        b_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        verifica_resultado();
        #5;

        
        s_tb = 3'd1; // A - B
        
        $display("-- Subtração com A > B");
        a_tb = 8'd210;  // 8'b1101_0010; 8'hD2
        b_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        verifica_resultado();
        #5;

        $display("-- Subtração com A < B (Underflow)");
        a_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        b_tb = 8'd210;  // 8'b1101_0010; 8'hD2
        verifica_resultado();
        #5;
        
        s_tb = 3'd2; // A * B
        
        $display("-- Muiltiplicacao sem overflow");
        a_tb = 8'd8;    // 8'b0000_1000; 8'h08
        b_tb = 8'd14;   // 8'b0000_1110; 8'h0E
        verifica_resultado();
        #5;
        
        $display("-- Muiltiplicacao com overflow");
        a_tb = 8'd5;    // 8'b0000_0101; 8'h05
        b_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        verifica_resultado();
        #5;
        
        s_tb = 3'd3; // A / B
        
        $display("-- Divisão exata");
        a_tb = 8'd93;   // 8'b0101_1101; 8'h5D
        b_tb = 8'd3;    // 8'b0000_0011; 8'h03
        verifica_resultado();
        #5;

        $display("-- Divisão com resto (quociente inteiro)");
        a_tb = 8'd40;   // 8'b0101_1101; 8'h5D
        b_tb = 8'd3;    // 8'b0000_0011; 8'h03
        verifica_resultado();
        #5;

        $display("-- Divisão por ZERO");
        a_tb = 8'd20;   // 8'b0101_1101; 8'h5D
        b_tb = 8'd0;    // 8'b0000_0011; 8'h03
        verifica_resultado();
        #5;
        
        s_tb = 3'd4; // A - 1

        a_tb = 8'd106;  // 8'b0110_1010; 8'h6A
        b_tb = 8'd82;   // 8'b0101_0010; 8'h52
        verifica_resultado();
        #5;
        
        s_tb = 3'd5; // B - 1
        verifica_resultado();
        #5;
        
        s_tb = 3'd6; // A + not(B)
        verifica_resultado();
        #5;
        
        s_tb = 3'd7; // not(A) + B
        verifica_resultado();
        #15;
        
        // ==========================================================
        // TESTE 03: Testes Aleatórios (10 vetores por operação = 160)
        // ==========================================================
        $display("\n===== TESTE 03: TESTES ALEATORIOS (160 VETORES) =====");
        for (int m_idx = 0; m_idx < 2; m_idx++) begin
            for (int s_idx = 0; s_idx < 8; s_idx++) begin
                repeat (10) begin
                    m_tb = m_idx[0];
                    s_tb = s_idx[2:0];
                    a_tb = 8'($urandom_range(0, 255));
                    b_tb = 8'($urandom_range(0, 255));
                    verifica_resultado(1'b0); // Silencioso se passar; imprime se falhar
                end
            end
        end

        // ==========================================================
        // RESUMO FINAL
        // ==========================================================
        $display("\n========================================");
        $display("          RESUMO DA SIMULACAO           ");
        $display("========================================");
        $display(" Total de testes executados : %0d", total_tests);
        $display(" Total de erros encontrados : %0d", error_count);
        if (error_count == 0)
            $display(" STATUS FINAL               : PASS");
        else
            $display(" STATUS FINAL               : FAIL");
        $display("========================================\n");

        $finish;
    end
endmodule
