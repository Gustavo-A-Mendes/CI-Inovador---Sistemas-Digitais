`timescale 1ns / 1ps
 
module tb;
 
    // Sinais de interconexao
    logic clk;
    logic reset;
    logic a;
    logic b;
    logic passo_a;
    logic passo_b;
    logic volta_a;
    logic volta_b;
 
    // Contadores de verificacao do testbench
    int cnt_passo_a;
    int cnt_passo_b;
    int cnt_volta_a;
    int cnt_volta_b;
    int error_count;
 
    // Instanciacao do DUT
    dec_encoder_rotativo dut (
        .clk     (clk),
        .reset   (reset),
        .a       (a),
        .b       (b),
        .passo_a (passo_a),
        .passo_b (passo_b),
        .volta_a (volta_a),
        .volta_b (volta_b)
    );
 
    // Geracao de clock de 100 ns (10 MHz)
    initial begin
        clk = 1'b0;
        forever #50 clk = ~clk;
    end
 
    // Monitor continuo de pulsos e verificacao de largura (estritamente 1 ciclo de clk)
    always @(posedge clk) begin
        if (!reset) begin
            if (passo_a) cnt_passo_a++;
            if (passo_b) cnt_passo_b++;
            if (volta_a) begin
                cnt_volta_a++;
                $display("[%0t ns] EVENTO: volta_a detectada!", $time);
            end
            if (volta_b) begin
                cnt_volta_b++;
                $display("[%0t ns] EVENTO: volta_b detectada!", $time);
            end
 
            // Verifica se qualquer pulso ativo permanece alto por mais de 1 ciclo
            if (passo_a || passo_b || volta_a || volta_b) begin
                logic pa_prev, pb_prev, va_prev, vb_prev;
                pa_prev = passo_a;
                pb_prev = passo_b;
                va_prev = volta_a;
                vb_prev = volta_b;
                @(posedge clk);
                if (!reset) begin
                    if ((pa_prev && passo_a) || (pb_prev && passo_b) ||
                        (va_prev && volta_a) || (vb_prev && volta_b)) begin
                        $error("[%0t ns] ERRO: Pulso de saida durou mais de 1 ciclo de clk!", $time);
                        error_count++;
                    end
                end
            end
        end
    end
 
    // Tarefa auxiliar: executa 1 passo completo no Sentido 1 (A -> B semi-sobreposto)
    task automatic girar_passo_a(input int ciclos_fase = 4);
        a = 1'b1; b = 1'b0; repeat (ciclos_fase) @(posedge clk); // 10
        a = 1'b1; b = 1'b1; repeat (ciclos_fase) @(posedge clk); // 11
        a = 1'b0; b = 1'b1; repeat (ciclos_fase) @(posedge clk); // 01
        a = 1'b0; b = 1'b0; repeat (ciclos_fase) @(posedge clk); // 00
    endtask
 
    // Tarefa auxiliar: executa 1 passo completo no Sentido 2 (B -> A semi-sobreposto)
    task automatic girar_passo_b(input int ciclos_fase = 4);
        a = 1'b0; b = 1'b1; repeat (ciclos_fase) @(posedge clk); // 01
        a = 1'b1; b = 1'b1; repeat (ciclos_fase) @(posedge clk); // 11
        a = 1'b1; b = 1'b0; repeat (ciclos_fase) @(posedge clk); // 10
        a = 1'b0; b = 1'b0; repeat (ciclos_fase) @(posedge clk); // 00
    endtask
 
    // Tarefa auxiliar: aplica reset
    task automatic apply_reset();
        reset = 1'b1;
        a     = 1'b0;
        b     = 1'b0;
        repeat (4) @(posedge clk);
        reset = 1'b0;
        repeat (2) @(posedge clk);
    endtask
 
    // Sequencia de testes
    initial begin
        $dumpfile("test.vcd");    // salva no arquivo com esse nome
        $dumpvars(0,tb);// salva todas as variáveis do módulo com o nome indicado

        $sdf_annotate("../src/dec_encoder_rotativo.sdf", tb.dut,, "sdf.log", "MAXIMUM");

        cnt_passo_a = 0;
        cnt_passo_b = 0;
        cnt_volta_a = 0;
        cnt_volta_b = 0;
        error_count = 0;
 
        apply_reset();
 
        $display("\n--- CASO 1: 3 passos em A seguidos de 3 passos em B (cancelamento) ---");
        repeat (3) girar_passo_a();
        repeat (3) girar_passo_b();
        repeat (3) @(posedge clk);
 
        if (cnt_passo_a != 3 || cnt_passo_b != 3 || cnt_volta_a != 0 || cnt_volta_b != 0) begin
            $error("Falha no Caso 1: pa=%0d, pb=%0d, va=%0d, vb=%0d",
                   cnt_passo_a, cnt_passo_b, cnt_volta_a, cnt_volta_b);
            error_count++;
        end
 
        $display("\n--- CASO 2: 16 passos consecutivos no Sentido 1 (volta_a) ---");
        repeat (16) girar_passo_a();
        repeat (3) @(posedge clk);
 
        if (cnt_passo_a != 19 || cnt_volta_a != 1 || cnt_volta_b != 0) begin
            $error("Falha no Caso 2: pa=%0d, va=%0d, vb=%0d",
                   cnt_passo_a, cnt_volta_a, cnt_volta_b);
            error_count++;
        end
 
        $display("\n--- CASO 3: 4 passos em A + 20 passos em B (subtracao e volta_b) ---");
        repeat (4)  girar_passo_a();
        repeat (19) girar_passo_b(); // Ate aqui: +4 - 19 = -15 (ainda nao completa volta_b)
        repeat (3) @(posedge clk);
 
        if (cnt_volta_b != 0) begin
            $error("Falha no Caso 3a: volta_b disparou antes de 16 passos liquidos em B!");
            error_count++;
        end
 
        girar_passo_b(); // 20o passo em B -> atinge -16 passos liquidos -> volta_b!
        repeat (3) @(posedge clk);
 
        if (cnt_volta_b != 1) begin
            $error("Falha no Caso 3b: volta_b nao disparou no 16o passo liquido em B!");
            error_count++;
        end
 
        // ---------------------------------------------------------------------
        $display("\n--- CASO 4: [%0t ns] Rejeicao de pulsos incompletos ---", $time);
        a = 1'b1; b = 1'b0; repeat (4) @(posedge clk);
        a = 1'b0; b = 1'b0; repeat (4) @(posedge clk); // Apenas A pulsou sem B
 
        a = 1'b0; b = 1'b1; repeat (4) @(posedge clk);
        a = 1'b0; b = 1'b0; repeat (4) @(posedge clk); // Apenas B pulsou sem A
 
        @(posedge clk);
        @(posedge clk);
 
        a = 1'b1; b = 1'b0; repeat (4) @(posedge clk); // Sobe A 
        a = 1'b1; b = 1'b1; repeat (4) @(posedge clk); // B pulsou sem A descer
        a = 1'b1; b = 1'b0; repeat (4) @(posedge clk); // 
        a = 1'b0; b = 1'b0; repeat (4) @(posedge clk); // Desce A
 
 
        if (cnt_passo_a != 23 || cnt_passo_b != 23) begin
            $error("Falha no Caso 4: falso passo detectado em pulso incompleto!");
            error_count++;
        end
 
        // ---------------------------------------------------------------------
        // CASO 5: Reset durante acumulacao parcial de passos
        // ---------------------------------------------------------------------
        $display("\n--- CASO 5: Reset limpa passos parciais ---");
        repeat (10) girar_passo_a();
        apply_reset();
        repeat (10) girar_passo_a(); // Sem reset teria atingido 20 passos (volta_a); com reset fica em 10
        repeat (3) @(posedge clk);
 
        if (cnt_volta_a != 1) begin
            $error("Falha no Caso 5: reset nao zerou a contagem interna de passos!");
            error_count++;
        end
 
        // Resumo final
        $display("\n==========================================");
        $display("Simulacao concluida | Erros: %0d", error_count);
        $display("passo_a: %0d | passo_b: %0d | volta_a: %0d | volta_b: %0d",
                 cnt_passo_a, cnt_passo_b, cnt_volta_a, cnt_volta_b);
        $display("==========================================\n");
        $finish;
    end
 
endmodule