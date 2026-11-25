// Testbench básico para módulo cdma_align
`timescale 1ns / 1ps

module tb_cdma_align;
    // Sinais de interconexao
    reg        clk;
    reg        reset;
    reg        di;
    reg  [7:0] padrao;
    wire       encontrado;
    wire [9:0] atraso;

    // Estatisticas do testbench
    integer pulse_count; // quantas vezes a saída pulsou indicando padrão encontrado no teste
    integer error_count;
    
    reg [9:0] captured_atraso=0; 

    // Instanciacao do DUT (Device Under Test)
    cdma_align dut (
        .clk                (clk),
        .reset              (reset),
        .di                 (di),
        .padrao             (padrao),
        .encontrado         (encontrado),
        .atraso             (atraso)
    );

    // Geracao de clock do sistema: periodo de 100 ns (50 ns alto / 50 ns baixo)
    initial begin
        clk = 1'b0;
        forever #50 clk = ~clk;
    end
    
    /* verilator lint_off BLKSEQ */
    always @(posedge clk) begin
        #1;
        if (!reset && encontrado) begin
            pulse_count     = pulse_count + 1;
            captured_atraso = atraso; 
            $display("[%0t ns] DETECTADO -> atraso = %0d bits", $time, atraso);

            @(posedge clk);
            #1;
            if (!reset && encontrado !== 1'b0) begin
                $display("[%0t ns] ERRO: 'encontrado' ficou ativo por mais de 1 ciclo de clk!", $time);
                error_count = error_count + 1;
            end
        end
    end
    /* verilator lint_on BLKSEQ */

    // Tarefa auxiliar: envia 1 bit em 'di' mantendo-o estavel por 8 ciclos de clk
    task send_bit;
        input b;
        begin
            di = b;
            repeat (8) @(posedge clk);
        end
    endtask

    // Tarefa auxiliar: envia uma palavra de 8 bits (MSB primeiro)
    task send_byte;
        input [7:0] data;
        integer idx;
        begin
            for (idx = 7; idx >= 0; idx = idx - 1) begin
                send_bit(data[idx]);
            end
            #2;
        end
    endtask

    // Tarefa auxiliar: aplica reset e configura novo padrao
    task apply_reset;
        input [7:0] novo_padrao;
        begin
            reset  = 1'b1;
            di     = 1'b0;
            padrao = novo_padrao;
            repeat (3) @(posedge clk);
            reset  = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("teste2.vcd");
        $dumpvars(0, tb_cdma_align);
    end

    initial begin
        pulse_count = 0;
        error_count = 0;

        // ---------------------------------------------------------------------
        $display("\n--- CASO 1: Padrao exato (8/8) ---");
        apply_reset(8'b1011_0010);
        send_byte(8'b1011_0010);

        if (pulse_count != 1 || captured_atraso !== 10'd8) begin
            $display("ERRO no Caso 1: pulse=%0d,captured_atraso=%0d",
                     pulse_count, captured_atraso);
            error_count = error_count + 1;
        end

        // ---------------------------------------------------------------------
        $display("\n--- CASO 2: Padrao apos 5 bits de captured_atraso ---");
        send_bit(1'b0);
        send_bit(1'b0);
        send_bit(1'b0);
        send_bit(1'b0);
        send_bit(1'b0);
        send_byte(8'b1011_0010);

        if (pulse_count != 2 || captured_atraso !== 10'd13) begin
            $display("ERRO no Caso 2: pulse=%0d, captured_atraso=%0d",
                     pulse_count, captured_atraso);
            error_count = error_count + 1;
        end

        // ---------------------------------------------------------------------
        $display("\n--- CASO 3: Padrao com 1 bit invertido (7/8) ---");
        send_byte(8'b1011_0011);

        if (pulse_count != 3 ||  captured_atraso !== 10'd8) begin
            $display("ERRO no Caso 3: pulse=%0d, captured_atraso=%0d",
                     pulse_count, captured_atraso);
            error_count = error_count + 1;
        end

        // ---------------------------------------------------------------------
        $display("\n--- CASO 4: Rejeicao de padrao com 2 bits de ruido (6/8) ---");
        send_byte(8'b1011_0001);

        if (pulse_count != 3) begin
            $display("ERRO no Caso 4: falso positivo com 6/8 bits!");
            error_count = error_count + 1;
        end

        // ---------------------------------------------------------------------
        $display("\n--- CASO 5: Overflow do contador atraso (> 1023 bits) ---");
        apply_reset(8'b1011_0010);
        repeat (1024) send_bit(1'b0);
        send_byte(8'b1011_0010);

        if (pulse_count != 4 ||  captured_atraso !== 10'd8) begin
            $display("ERRO no Caso 5: pulse=%0d, captured_atraso=%0d",
                     pulse_count, captured_atraso);
            error_count = error_count + 1;
        end

        // ---------------------------------------------------------------------
        $display("\n--- CASO 6: Reset e troca de padrao ---");
        send_bit(1'b1);
        send_bit(1'b1);
        apply_reset(8'b1100_1010);
        send_byte(8'b1100_1010);

        if (pulse_count != 5 || captured_atraso !== 10'd8) begin
            $display("ERRO no Caso 6: pulse=%0d, captured_atraso=%0d",
                     pulse_count, captured_atraso);
            error_count = error_count + 1;
        end

        // Resumo final
        repeat (4) @(posedge clk);
        $display("\n==========================================");
        $display("Simulacao concluida: %0d deteccoes | %0d erros", pulse_count, error_count);
        $display("==========================================\n");
        $finish;
    end

endmodule
