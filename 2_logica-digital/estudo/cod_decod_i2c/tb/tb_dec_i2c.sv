`timescale 1ns / 1ps

module tb_dec_i2c;

    // Parâmetros de temporização conforme enunciado (Item 2.1)
    localparam time CLK_PERIOD     = 10ns;  // 100 MHz
    localparam time SCL_HALF_PHASE = 50ns;  // Período SCL = 100 ns

    // Sinais de conexão com o DUT
    logic       clk;
    logic       reset;
    logic       sda;
    logic       scl;
    logic       pronto;
    logic [6:0] endereco_local;
    logic [6:0] endereco_recebido;
    logic       operacao;
    logic       escrita;
    logic       stop;

    // Controle e contadores para verificação automática dos pulsos
    logic clear_counts;
    int   escrita_pulses;
    int   stop_pulses;

    // Instanciação do Device Under Test (DUT)
    dec_i2c dut (
        .clk               (clk),
        .reset             (reset),
        .sda               (sda),
        .scl               (scl),
        .pronto            (pronto),
        .endereco_local    (endereco_local),
        .endereco_recebido (endereco_recebido),
        .operacao          (operacao),
        .escrita           (escrita),
        .stop              (stop)
    );

    // Geração do clock do sistema (10 ns)
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Único driver síncrono para os contadores de pulso (compatível com Xcelium)
    always_ff @(posedge clk) begin
        if (reset || clear_counts) begin
            escrita_pulses <= 0;
            stop_pulses    <= 0;
        end else begin
            if (escrita) escrita_pulses <= escrita_pulses + 1;
            if (stop)    stop_pulses    <= stop_pulses + 1;
        end
    end

    // -------------------------------------------------------------------------
    // Tasks auxiliares para controle e eventos físicos do barramento I2C
    // -------------------------------------------------------------------------
    task automatic reset_counters();
        begin
            @(posedge clk);
            clear_counts = 1'b1;
            @(posedge clk);
            clear_counts = 1'b0;
        end
    endtask

    task automatic i2c_start();
        begin
            sda = 1'b1;
            scl = 1'b1;
            #(SCL_HALF_PHASE);
            sda = 1'b0; // Borda de descida de SDA com SCL = 1 (Start Condition)
            #(SCL_HALF_PHASE);
            scl = 1'b0; // Prepara barramento para transmissão de dados
            #(SCL_HALF_PHASE / 2);
        end
    endtask

    task automatic i2c_send_bit(input logic bit_val);
        begin
            // Muda SDA apenas quando SCL está em nível baixo
            sda = bit_val;
            #(SCL_HALF_PHASE / 2);
            scl = 1'b1; // Borda de subida de SCL (amostragem pelo receptor)
            #(SCL_HALF_PHASE);
            scl = 1'b0; // Borda de descida de SCL
            #(SCL_HALF_PHASE / 2);
        end
    endtask

    task automatic i2c_stop();
        begin
            sda = 1'b0;
            #(SCL_HALF_PHASE / 2);
            scl = 1'b1; // Sobe SCL primeiro
            #(SCL_HALF_PHASE);
            sda = 1'b1; // Borda de subida de SDA com SCL = 1 (Stop Condition)
            #(SCL_HALF_PHASE);
        end
    endtask

    task automatic send_i2c_frame(input logic [6:0] addr, input logic rw_bit);
        begin
            i2c_start();
            // Envia MSB primeiro (índice 6 até 0) - Item 2.3
            for (int i = 6; i >= 0; i--) begin
                i2c_send_bit(addr[i]);
            end
            // Envia 8º bit (READ = 1 / WRITE = 0) - Item 2.4
            i2c_send_bit(rw_bit);
            // Simula o 9º ciclo de clock do bit ACK/NACK mostrado na figura
            i2c_send_bit(1'b0);
            i2c_stop();
        end
    endtask

    // -------------------------------------------------------------------------
    // Sequência Principal de Testes
    // -------------------------------------------------------------------------
    initial begin
        // Exporta arquivo de ondas (SimVision / GTKWave)
        $dumpfile("tb_dec_i2c.vcd");
        $dumpvars(0, tb_dec_i2c);

        // Inicialização
        reset          = 1'b1;
        clear_counts   = 1'b0;
        sda            = 1'b1;
        scl            = 1'b1;
        pronto         = 1'b0;
        endereco_local = 7'b1100100; // Constante exigida no Item 2.1

        repeat (5) @(posedge clk);
        reset = 1'b0;
        repeat (5) @(posedge clk);

        $display("\n=== INICIANDO VERIFICACAO DO DECODIFICADOR I2C ===");

        // ---------------------------------------------------------------------
        // TESTE 1: Caso da Figura (Endereco 7'b1100100 + Write 0)
        // ---------------------------------------------------------------------
        pronto = 1'b1;
        reset_counters();

        send_i2c_frame(7'b1100100, 1'b0);
        repeat (5) @(posedge clk);

        assert (endereco_recebido === 7'b1100100)
            else $error("[FALHA T1] Endereco esperado: 1100100, obtido: %b", endereco_recebido);
        assert (operacao === 1'b0)
            else $error("[FALHA T1] Operacao esperada: 0, obtida: %b", operacao);
        assert (escrita_pulses == 1)
            else $error("[FALHA T1] Pulso 'escrita' esperado: 1, obtido: %0d", escrita_pulses);
        assert (stop_pulses == 1)
            else $error("[FALHA T1] Pulso 'stop' esperado: 1, obtido: %0d", stop_pulses);
        $display("[PASS] Teste 1: Endereco correto + Write (0) validado com sucesso.");

        // ---------------------------------------------------------------------
        // TESTE 2: Endereco Correto + Operacao de Leitura (Read = 1)
        // ---------------------------------------------------------------------
        reset_counters();

        send_i2c_frame(7'b1100100, 1'b1);
        repeat (5) @(posedge clk);

        assert (operacao === 1'b1)
            else $error("[FALHA T2] Operacao esperada: 1, obtida: %b", operacao);
        assert (escrita_pulses == 0)
            else $error("[FALHA T2] 'escrita' nao deveria pulsar em leitura!");
        assert (stop_pulses == 1)
            else $error("[FALHA T2] Pulso 'stop' esperado: 1, obtido: %0d", stop_pulses);
        $display("[PASS] Teste 2: Endereco correto + Read (1) validado com sucesso.");

        // ---------------------------------------------------------------------
        // TESTE 3: Endereco Incorreto (7'b1010101) + Write (0)
        // ---------------------------------------------------------------------
        reset_counters();

        send_i2c_frame(7'b1010101, 1'b0);
        repeat (5) @(posedge clk);

        assert (endereco_recebido === 7'b1010101)
            else $error("[FALHA T3] Endereco esperado: 1010101, obtido: %b", endereco_recebido);
        assert (escrita_pulses == 0)
            else $error("[FALHA T3] 'escrita' nao deveria pulsar para outro endereco!");
        $display("[PASS] Teste 3: Endereco diferente ignorado corretamente.");

        // ---------------------------------------------------------------------
        // TESTE 4: Tentativa de transacao com 'pronto == 0'
        // ---------------------------------------------------------------------
        pronto = 1'b0;
        reset_counters();

        send_i2c_frame(7'b1100100, 1'b0);
        repeat (5) @(posedge clk);

        assert (escrita_pulses == 0)
            else $error("[FALHA T4] Modulo capturou quadro mesmo com pronto=0!");
        $display("[PASS] Teste 4: Bloqueio por 'pronto = 0' validado.");

        $display("=== TODOS OS TESTES CONCLUIDOS COM SUCESSO ===\n");
        $finish;
    end

endmodule