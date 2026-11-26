`timescale 1ns/1ps

module tb_ula;

    logic [7:0] a_tb, b_tb, f_tb;
    logic [2:0] s_tb;
    logic       m_tb;

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
    
    task automatic exibe_resultado();
        logic only_opA, only_opB;

        #1;
        // Exibe a operação sendo feita:
        $display("===== OPERACAO %1d: %s =====", s_tb, operacoes[s_tb][m_tb]);

        // Exibe operandos de interesse e o resultado
        only_opA = (( m_tb && (s_tb == 3'd0) ) || ( ~m_tb && (s_tb == 3'd4) ));
        only_opB = (( m_tb && (s_tb == 3'd7) ) || ( ~m_tb && (s_tb == 3'd5) ));

        if (only_opA) begin
            $display(">> A=%3d (%02h | %08b ) \n\n>> F=%3d (%02h | %08b )\n", 
                        a_tb, a_tb, a_tb,
                        f_tb, f_tb, f_tb
            );
        end
        else if (only_opB) begin
            $display(">> B=%3d (%02h | %08b ) \n\n>> F=%3d (%02h | %08b )\n", 
                        b_tb, b_tb, b_tb, 
                        f_tb, f_tb, f_tb
            );
        end
        else begin
            $display(">> A=%3d (%02h | %08b ) \n>> B=%3d (%02h | %08b ) \n\n>> F=%3d (%02h | %08b )\n\n",
                        a_tb, a_tb, a_tb,
                        b_tb, b_tb, b_tb,
                        f_tb, f_tb, f_tb
            );
        end

    endtask //automatic


    // Gerando Estímulos:
    initial begin
        $dumpfile("tb_ula.vcd");
        $dumpvars(0, tb_ula);

        // Inicializa sinais:
        a_tb = 8'd0; b_tb = 8'd0; s_tb = 3'd0; m_tb = 1'b0;
        #10;

        // Teste 01: Operadores Lógicos (M = 1)
        m_tb = 1'b1;
        
        a_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        b_tb = 8'd210;  // 8'b1101_0010; 8'hD2
        
        $display("\n\n");
        $display("===== TESTE 01: OPERADORES LOGICOS (M = 1) =====");
        $display("A=%3d (%02h | %08b ), B=%3d (%02h | %08b )", a_tb, a_tb, a_tb, b_tb, b_tb, b_tb);
        
        s_tb = 3'd0; // not(A)
        exibe_resultado();
        #5;

        s_tb = 3'd1; // not(A or B)
        exibe_resultado();
        #5;
        
        s_tb = 3'd2; // not(A and B)
        exibe_resultado();
        #5;
        
        s_tb = 3'd3; // not(A xor B)
        exibe_resultado();
        #5;
        
        s_tb = 3'd4; // not(A and B)
        exibe_resultado();
        #5;
        
        s_tb = 3'd5; // not(A or B)
        exibe_resultado();
        #5;
        
        s_tb = 3'd6; // not(A xor B)
        exibe_resultado();
        #5;
        
        s_tb = 3'd7; // not(B)
        exibe_resultado();
        #15;
        
        // Teste 02: Operadores Aritméticos (M = 1)
        m_tb = 1'b0;

        a_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        b_tb = 8'd210;  // 8'b1101_0010; 8'hD2
        
        $display("===== TESTE 02: OPERADORES ARITMETICOS (M = 0) =====");
        $display("A=%3d (%02h | %08b ), B=%3d (%02h | %08b )", a_tb, a_tb, a_tb, b_tb, b_tb, b_tb);
        
        s_tb = 3'd0; // A + B
        
        // Sem overflow
        a_tb = 8'd18;   // 8'b0001_0010; 8'h12
        b_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        exibe_resultado();
        #5;
        
        // Com overflow
        a_tb = 8'd210;  // 8'b1101_0010; 8'hD2
        b_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        exibe_resultado();
        #5;

        
        s_tb = 3'd1; // A - B
        
        // A > B
        a_tb = 8'd210;  // 8'b1101_0010; 8'hD2
        b_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        exibe_resultado();
        #5;

        // A < B
        a_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        b_tb = 8'd210;  // 8'b1101_0010; 8'hD2
        exibe_resultado();
        #5;
        
        s_tb = 3'd2; // A * B
        
        // Sem overflow
        a_tb = 8'd8;    // 8'b0000_1000; 8'h08
        b_tb = 8'd14;   // 8'b0000_1110; 8'h0E
        exibe_resultado();
        #5;
        
        // Com overflow
        a_tb = 8'd5;    // 8'b0000_0101; 8'h05
        b_tb = 8'd74;   // 8'b0100_1010; 8'h4A
        exibe_resultado();
        #5;
        
        s_tb = 3'd3; // A / B
        
        a_tb = 8'd93;   // 8'b0101_1101; 8'h5D
        b_tb = 8'd3;    // 8'b0000_0011; 8'h03
        exibe_resultado();
        #5;
        
        s_tb = 3'd4; // A - 1

        a_tb = 8'd106;  // 8'b0110_1010; 8'h6A
        b_tb = 8'd82;   // 8'b0101_0010; 8'h52
        exibe_resultado();
        #5;
        
        s_tb = 3'd5; // B - 1
        exibe_resultado();
        #5;
        
        s_tb = 3'd6; // A + not(B)
        exibe_resultado();
        #5;
        
        s_tb = 3'd7; // not(A) + B
        exibe_resultado();
        #15;
        
        $finish(2);
    end
endmodule
