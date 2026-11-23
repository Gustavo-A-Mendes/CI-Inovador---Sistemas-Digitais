`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2026 02:34:34 PM
// Design Name: 
// Module Name: tb_neander_vivado
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_neander;
    
    // 1. Sinais conectados exclusivamente às portas do Top-Level (100% compatível com Pós-Síntese!)
    logic       clk_tb;
    logic       rst_n_tb;
    logic       hlt_tb;
    logic [7:0] ac_tb, pc_tb, rem_tb, rdm_tb, ri_tb, mem_out_tb, t_tb;
    logic       mem_wen_tb;
    logic       mem_ren_tb;
    logic [3:0] inst_code_tb;
    logic [2:0] op_code_tb;

    // 2. Instanciando o Chip (Device Under Test)
    neander #(
        `ifndef GATE_LEVEL
        .MEM_FILE(MEM_FILE)
        `endif
    ) dut (
        .clk_i      (clk_tb),
        .rst_n_i    (rst_n_tb),
        .hlt_o      (hlt_tb),
        .ac_o       (ac_tb),
        .pc_o       (pc_tb),
        .rem_o      (rem_tb),
        .rdm_o      (rdm_tb),
        .ri_o       (ri_tb),
        .mem_out_o  (mem_out_tb),
        .mem_wen_o  (mem_wen_tb),
        .mem_ren_o  (mem_ren_tb),
        .t_o        (t_tb),
        .inst_code_o(inst_code_tb),
        .op_code_o  (op_code_tb)
    );

    // 3. Geração do Clock (50 MHz -> Período de 20ns)
    initial begin
        clk_tb = 1'b0;
        forever #10 clk_tb = ~clk_tb;
    end

    // =========================================================================
    // 4. Contadores de Desempenho (Ciclos e Instruções para a Tabela Final!)
    // =========================================================================
    int ciclo_count = 0;
    int inst_count  = 0;

    always @(posedge clk_tb) begin
        if (rst_n_tb && !hlt_tb) begin
            ciclo_count <= ciclo_count + 1;
            // Cada instrução passa exatamente 1 ciclo pelo estado t0 (Busca do Opcode)
            if (t_tb == 8'b0000_0001) begin
                inst_count <= inst_count + 1;
            end
        end
    end

    // 5. Shadow Memory Dinâmica (Aprende os dados lidos e escritos na BRAM)
    logic [7:0] dump_mem [0:255];
    
    initial begin
        for (int k = 0; k < 256; k++) dump_mem[k] = 8'h00;
    end

    // Na borda de subida, só copia mem_out_tb se o ciclo que acabou de terminar
    // foi de fato uma Operação B (mem_ren_tb == 1)!
    always @(posedge clk_tb) begin
        if (rst_n_tb && mem_ren_tb) begin
            dump_mem[rem_tb] <= mem_out_tb;
        end
    end

    // Captura toda escrita feita pelo Neander na BRAM:
    always @(negedge clk_tb) begin
        if (rst_n_tb && mem_wen_tb) begin
            dump_mem[rem_tb] <= rdm_tb;
            $display("[MEM WRITE] t=%0t ns | Endereco 0x%02h <= Dado 0x%02h (%0d)", 
                     $time, rem_tb, rdm_tb, $signed(rdm_tb));
        end
    end

    // 6. Sequência de Reset (120ns para aguardar o GSR da Xilinx na simulação pós-síntese)
    initial begin
        rst_n_tb = 1'b0;
        #120;
        @(negedge clk_tb);
        rst_n_tb = 1'b1;
    end

    // 7. Timeout de Segurança (200 us)
    initial begin
        #200000; 
        $display("[TIMEOUT] A simulacao atingiu o tempo limite sem encontrar HLT!");
        $finish;
    end

    // =========================================================================
    // 8. Monitor Self-Checking com Golden Model (Scoreboard Profissional)
    // =========================================================================
    // Selecione qual programa validar (ou deixe 0 para autodetectar pelo código!)
    // 0 = Auto | 1 = Teste Simples (@80 = @81 op @82) | 2 = Multiplicação | 3 = Matrizes 3x3
    localparam int MODO_TESTE = 2; 

    initial begin
        int erros;
        int modo_ativo;
        logic [7:0] esperado;

        wait (rst_n_tb == 1'b1 && hlt_tb == 1'b1);
        @(posedge clk_tb);

        // Soma +1 ciclo/instrução caso queira contabilizar até o final do HLT
        $display("\n================================================================");
        $display("[INFO] HLT detectado em t = %0t ns!", $time);
        $display("[PERF] Instrucoes Executadas : %0d", inst_count);
        $display("[PERF] Ciclos de Relogio     : %0d c.c.", ciclo_count);
        $display("[PERF] Tempo @ 50MHz (20ns)  : %0d ns (%0.2f us)", ciclo_count * 20, (ciclo_count * 20.0) / 1000.0);
        $display("[REGS] AC final = 0x%02h (%0d) | PC final = 0x%02h", ac_tb, $signed(ac_tb), pc_tb);
        $display("================================================================\n");

        // Imprime o mapa de memória atualizado (16x16)
        $display("    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F");
        $display("   ------------------------------------------------");
        for (int linha = 0; linha < 16; linha++) begin
            $display("%01h0 | %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h", 
                linha, 
                dump_mem[16*linha + 4'h0], dump_mem[16*linha + 4'h1], 
                dump_mem[16*linha + 4'h2], dump_mem[16*linha + 4'h3], 
                dump_mem[16*linha + 4'h4], dump_mem[16*linha + 4'h5], 
                dump_mem[16*linha + 4'h6], dump_mem[16*linha + 4'h7], 
                dump_mem[16*linha + 4'h8], dump_mem[16*linha + 4'h9], 
                dump_mem[16*linha + 4'hA], dump_mem[16*linha + 4'hB], 
                dump_mem[16*linha + 4'hC], dump_mem[16*linha + 4'hD], 
                dump_mem[16*linha + 4'hE], dump_mem[16*linha + 4'hF]);
        end
        $display("");

        // ---------------------------------------------------------------------
        // Autodetecção ou Seleção do Golden Model (Scoreboard)
        // ---------------------------------------------------------------------
        erros = 0;
        if (MODO_TESTE != 0) begin
            modo_ativo = MODO_TESTE;
        end else if (dump_mem[8'h06] == 8'hF0) begin
            modo_ativo = 1; // Programa curto de 7 bytes (HLT em 0x06)
        end else if (dump_mem[8'h06] == 8'hA0) begin
            modo_ativo = 2; // Multiplicação (tem JZ em 0x06)
        end else begin
            modo_ativo = 3; // Subtração de Matrizes 3x3
        end

        case (modo_ativo)
            // -----------------------------------------------------------------
            // CASO 1: Teste Simples de Soma (0x30) ou Subtração (0x70)
            // Mapa: 0x80 = Resultado | 0x81 = Op1 | 0x82 = Op2
            // -----------------------------------------------------------------
            1: begin
                esperado = (dump_mem[8'h03] == 8'h70) ? (dump_mem[8'h80] - dump_mem[8'h81]) 
                                                      : (dump_mem[8'h80] + dump_mem[8'h81]);
                assert (dump_mem[8'h82] === esperado)
                    $display("[PASS] Operacao Basica OK! Mem[0x80] = %0d (Esperado: %0d)", 
                             $signed(dump_mem[8'h82]), $signed(esperado));
                else begin
                    $error("[FAIL] Mem[0x80] = %0d | Esperado = %0d", 
                           $signed(dump_mem[8'h82]), $signed(esperado));
                    erros++;
                end
            end

            // -----------------------------------------------------------------
            // CASO 2: Multiplicação por Somas Sucessivas
            // Mapa: 0x80 = A | 0x81 = B | 0x82 = Resultado (A * B)
            // -----------------------------------------------------------------
            2: begin
                esperado = dump_mem[8'h80] * dump_mem[8'h81];
                assert (dump_mem[8'h82] === esperado)
                    $display("[PASS] Multiplicacao OK! %0d * %0d = %0d (Mem[0x82] = 0x%02h)", 
                             dump_mem[8'h80], dump_mem[8'h81], dump_mem[8'h82], dump_mem[8'h82]);
                else begin
                    $error("[FAIL] Multiplicacao falhou! %0d * %0d -> Obtido: %0d | Esperado: %0d", 
                           dump_mem[8'h80], dump_mem[8'h81], dump_mem[8'h82], esperado);
                    erros++;
                end
            end

            // -----------------------------------------------------------------
            // CASO 3: Subtração de Matrizes 3x3 (9 elementos em Compl. de 2)
            // Mapa: Matriz A [0x80..0x88], Matriz B [0x89..0x91], Matriz C [0x92..0x9A]
            // -----------------------------------------------------------------
            3: begin
                $display("--- Validando Matriz Resultante C[3x3] = A[3x3] - B[3x3] ---");
                for (int idx = 0; idx < 9; idx++) begin
                    logic [7:0] val_a, val_b, val_c;
                    val_a    = dump_mem[8'h80 + idx];
                    val_b    = dump_mem[8'h89 + idx];
                    val_c    = dump_mem[8'h92 + idx];
                    esperado = val_a - val_b;

                    assert (val_c === esperado)
                        $display("  [OK] Elem[%0d]: %4d - %4d = %4d (Mem[0x%02h] = 0x%02h)", 
                                 idx, $signed(val_a), $signed(val_b), $signed(val_c), (8'h92 + idx), val_c);
                    else begin
                        $error("  [ERRO] Elem[%0d] (Mem[0x%02h]): %0d - %0d -> Obtido: %0d | Esperado: %0d", 
                               idx, (8'h92 + idx), $signed(val_a), $signed(val_b), $signed(val_c), $signed(esperado));
                        erros++;
                    end
                end
                if (erros == 0)
                    $display("[PASS] Subtracao de Matrizes 3x3 100%% validada sem erros!");
            end
        endcase

        $finish;
    end
    
    

endmodule