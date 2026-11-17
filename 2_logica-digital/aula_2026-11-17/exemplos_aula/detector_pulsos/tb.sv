`timescale 1ns/1ps

module tb();

    logic clk, reset, a, b;
    logic seq_a, seq_b;

    detector_pulso dut (
        .clk(clk), .reset(reset), .a(a), .b(b),
        .seq_a(seq_a), .seq_b(seq_b)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Tarefa: Envia um pulso LONGO na entrada A (Dura 3 ciclos de clock)
    task send_long_pulse_a();
        @(negedge clk); a = 1;
        repeat(3) @(negedge clk); // Mantém A em nível alto
        a = 0;
        @(negedge clk);           // Espaço antes do próximo pulso
    endtask

    // Tarefa: Envia um pulso LONGO na entrada B (Dura 4 ciclos de clock)
    task send_long_pulse_b();
        @(negedge clk); b = 1;
        repeat(4) @(negedge clk); // Mantém B em nível alto
        b = 0;
        @(negedge clk);
    endtask

    // Verificação Automática do pulso de 1 ciclo (Self-checking)
    logic prev_seq_a, prev_seq_b;
    always_ff @(posedge clk) begin
        if (!reset) begin
            prev_seq_a <= seq_a;
            prev_seq_b <= seq_b;
            if (prev_seq_a && seq_a) 
                $error("FALHA: seq_a durou mais de 1 ciclo!");
            if (prev_seq_b && seq_b) 
                $error("FALHA: seq_b durou mais de 1 ciclo!");
        end
    end

    // Estímulos
    initial begin
        reset = 1; a = 0; b = 0;
        repeat(3) @(negedge clk);
        reset = 0;

        $display("--- INICIANDO TESTES (COM PULSOS LONGOS) ---");

        // TESTE 1: 3 subidas em A, intercaladas por tempos longos em alta
        $display("Teste 1: Enviando 3 pulsos LONGOS em A...");
        send_long_pulse_a(); 
        send_long_pulse_a(); 
        send_long_pulse_a(); // seq_a deve pulsar por 1 ciclo aqui
        
        repeat(3) @(negedge clk);

        // TESTE 2: 3 subidas em B
        $display("Teste 2: Enviando 3 pulsos LONGOS em B...");
        send_long_pulse_b(); 
        send_long_pulse_b(); 
        send_long_pulse_b(); // seq_b deve pulsar por 1 ciclo aqui
        
        repeat(3) @(negedge clk);

        // TESTE 3: Cancelamento de sequências longas
        $display("Teste 3: Intercalando A e B...");
        send_long_pulse_a(); // 1 pulso em A
        send_long_pulse_b(); // Borda de B zera a contagem de A
        send_long_pulse_a(); 
        send_long_pulse_b(); 

        repeat(5) @(negedge clk);
        $display("--- TESTES CONCLUIDOS COM SUCESSO ---");
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

endmodule