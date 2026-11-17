`timescale 1ns/1ps

module tb_neander;

    // 1. Sinais de Estímulo (Energia)
    logic clk_tb;
    logic rst_n_tb;
    logic htl_tb;

    // 2. Instanciando o Chip (Device Under Test)
    neander dut (
        .clk_i   (clk_tb),
        .rst_n_i (rst_n_tb),
        .hlt_o   (htl_tb)
    );

    // 3. Geração do Clock (100 MHz)
    initial begin
        clk_tb = 1'b0;
        forever #5 clk_tb = ~clk_tb;
    end

    initial begin
        $dumpfile("tb_neander_result.vcd");
        $dumpvars(0, tb_neander);
    end

    // 4. Geração do Reset Assíncrono (Ativo em Baixo)
    initial begin

    end

    // 4 e 5. Geração do Reset Assíncrono (Ativo em Baixo) e Carga do Firmware (Instante Zero)
    initial begin
        rst_n_tb = 1'b0;
        $readmemh("../tb/program.mem", dut.ND_MEM0.sram);

        #100; @(negedge clk_tb);
        rst_n_tb = 1'b1;
    end

    // 6. Timeout de Segurança (Para o simulador não travar em loop infinito)
    initial begin
        #10000; 
        $display("faiô!");
        $finish;
    end
    // 7. Monitor Self-Checking (Fim de Programa)
    initial begin
        // O Testbench para nesta linha e fica "espiando" o fio hlt no silício
        @(posedge rst_n_tb);
        wait (dut.ctrl_dpath_bus.ctrl_sgn.hlt === 1'b1);
        @(posedge clk_tb);

        $display("[INFO] Sinal HLT detectado! O processador terminou a execucao.\n");

        $display("    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F\n");

        for (int i = 0; i < 16; i++) begin
            $display("%01h0  %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h", 
            (i), 
            dut.ND_MEM0.sram[16*i + 4'h0], 
            dut.ND_MEM0.sram[16*i + 4'h1], 
            dut.ND_MEM0.sram[16*i + 4'h2], 
            dut.ND_MEM0.sram[16*i + 4'h3], 
            dut.ND_MEM0.sram[16*i + 4'h4], 
            dut.ND_MEM0.sram[16*i + 4'h5], 
            dut.ND_MEM0.sram[16*i + 4'h6], 
            dut.ND_MEM0.sram[16*i + 4'h7], 
            dut.ND_MEM0.sram[16*i + 4'h8], 
            dut.ND_MEM0.sram[16*i + 4'h9], 
            dut.ND_MEM0.sram[16*i + 4'hA], 
            dut.ND_MEM0.sram[16*i + 4'hB], 
            dut.ND_MEM0.sram[16*i + 4'hC], 
            dut.ND_MEM0.sram[16*i + 4'hD], 
            dut.ND_MEM0.sram[16*i + 4'hE], 
            dut.ND_MEM0.sram[16*i + 4'hF]);
        end

        // O programa somou 2+3 e guardou no endereco 0x80. Vamos checar o array da SRAM:
        if (dut.ND_MEM0.sram[8'h80] == 8'h05) begin
            $display("========================================");
            $display("[PASS] SUCESSO! A ULA calculou corretamente.");
            $display("========================================");
        end 
        else begin
            $error("[FAIL] ERRO FATAL! Valor esperado: 05, Valor lido: %h", dut.ND_MEM0.sram[8'h80]);
        end

        // Encerra a simulação automaticamente, sem depender do Timeout
        $finish;
    end

endmodule