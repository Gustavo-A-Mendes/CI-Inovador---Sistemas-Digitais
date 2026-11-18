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
    logic [3:0] inst_code_tb;
    logic [2:0] op_code;

    // 2. Instanciando o Chip (Device Under Test)
    neander dut (
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

    // 4. Contador de Ciclos de Relógio (para a tabela de desempenho do relatório!)
    int ciclo_count = 0;
    always @(posedge clk_tb) begin
        if (rst_n_tb && !hlt_tb) begin
            ciclo_count <= ciclo_count + 1;
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

    // 8. Monitor de Encerramento (Observando apenas a porta externa hlt_tb!)
    initial begin
        wait (rst_n_tb == 1'b1 && hlt_tb == 1'b1);
        @(posedge clk_tb);

        $display("\n================================================================");
        $display("[INFO] HLT detectado em t = %0t ns!", $time);
        $display("[PERF] Total de Ciclos Executados: %0d c.c. | Tempo @ 50MHz: %0d ns", 
                 ciclo_count, ciclo_count * 20);
        $display("[REGS] AC final = 0x%02h | PC final = 0x%02h", ac_tb, pc_tb);
        $display("================================================================\n");

        // Imprime o mapa de memória atualizado (16x16) no Tcl Console
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
        
        // Verificação Automática (Exemplo para instrução SUB 0x70 e ADD 0x30)
        if (dump_mem[8'h02] == 8'h70) begin
            assert (dump_mem[8'h80] == (dump_mem[8'h81] - dump_mem[8'h82]))
                $display("[PASS] Subtracao validada com sucesso! (%0d - %0d = %0d)", 
                         dump_mem[8'h81], dump_mem[8'h82], $signed(dump_mem[8'h80]));
            else
                $error("[FAIL] Erro na Subtracao! Esperado: %0d, Obtido: %0d", 
                       (dump_mem[8'h81] - dump_mem[8'h82]), $signed(dump_mem[8'h80]));
        end
        $finish;
    end
    
    

endmodule
