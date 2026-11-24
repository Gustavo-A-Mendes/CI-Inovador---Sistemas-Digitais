`timescale 1ns / 1ps

module dec_i2c (
    input  logic       clk,
    input  logic       reset,
    input  logic       sda,
    input  logic       scl,
    input  logic       pronto,
    input  logic [6:0] endereco_local,
    output logic [6:0] endereco_recebido,
    output logic       operacao,
    output logic       escrita,
    output logic       stop
);

    // Codificação dos estados da FSM
    typedef enum logic [1:0] {
        S_IDLE      = 2'b00,
        S_CAP_ADDR  = 2'b01,
        S_CAP_OP    = 2'b10,
        S_WAIT_STOP = 2'b11
    } state_t;

    state_t state_q, state_d;

    // Registradores de dados e controle
    logic [6:0] addr_ff;
    logic [2:0] bit_cnt_q, bit_cnt_d;
    logic       op_q;
    logic       escrita_q, escrita_d;
    logic       stop_q;

    // Registradores de sincronização (2 estágios) e detecção de borda
    logic sda_sync0, sda_sync1, sda_prev;
    logic scl_sync0, scl_sync1, scl_prev;

    // Sinais internos de 1 ciclo de clk (Item 2.2)
    logic sobe_scl;
    logic start_cond;
    logic stop_cond;

    // -------------------------------------------------------------------------
    // 1. Sincronização de entradas assíncronas e amostragem do ciclo anterior
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            {sda_sync0, sda_sync1, sda_prev} <= 3'b111; // Pull-up ocioso
            {scl_sync0, scl_sync1, scl_prev} <= 3'b111;
        end else begin
            sda_sync0 <= sda;
            sda_sync1 <= sda_sync0;
            sda_prev  <= sda_sync1;

            scl_sync0 <= scl;
            scl_sync1 <= scl_sync0;
            scl_prev  <= scl_sync1;
        end
    end

    // Detecção combinacional das bordas e condições de controle I2C
    always_comb begin
        sobe_scl   = (~scl_prev) & scl_sync1;                // SCL: 0 -> 1
        start_cond = (sda_prev & (~sda_sync1)) & scl_sync1;  // SDA: 1 -> 0 com SCL = 1
        stop_cond  = ((~sda_prev) & sda_sync1) & scl_sync1;  // SDA: 0 -> 1 com SCL = 1
    end

    // -------------------------------------------------------------------------
    // 2. Lógica Sequencial: FSM, Registrador de Endereço (addr_ff) e Saídas
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            state_q   <= S_IDLE;
            bit_cnt_q <= 3'd6;
            addr_ff   <= 7'd0;
            op_q      <= 1'b0;
            escrita_q <= 1'b0;
            stop_q    <= 1'b0;
        end else begin
            state_q   <= state_d;
            bit_cnt_q <= bit_cnt_d;
            escrita_q <= escrita_d;
            stop_q    <= stop_cond; // Pulso de 1 ciclo de clk na saída stop (Item 2.6)

            // Limpa registradores ao iniciar nova transação válida
            if (state_q == S_IDLE && pronto && start_cond) begin
                addr_ff <= 7'd0;
                op_q    <= 1'b0;
            end 
            // Captura os 7 bits de endereço (MSB primeiro: índice 6 até 0)
            else if (state_q == S_CAP_ADDR && sobe_scl) begin
                addr_ff[bit_cnt_q] <= sda_sync1;
            end 
            // Captura o 8º bit (operação Read/Write)
            else if (state_q == S_CAP_OP && sobe_scl) begin
                op_q <= sda_sync1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // 3. Lógica Combinacional de Próximo Estado e Pulso de Escrita
    // -------------------------------------------------------------------------
    always_comb begin
        state_d   = state_q;
        bit_cnt_d = bit_cnt_q;
        escrita_d = 1'b0;

        // Condição de STOP encerra a transação imediatamente de qualquer estado
        if (stop_cond) begin
            state_d   = S_IDLE;
            bit_cnt_d = 3'd6;
        end else begin
            case (state_q)
                S_IDLE: begin
                    bit_cnt_d = 3'd6;
                    if (pronto && start_cond) begin
                        state_d = S_CAP_ADDR;
                    end
                end

                S_CAP_ADDR: begin
                    if (sobe_scl) begin
                        if (bit_cnt_q == 3'd0) begin
                            state_d = S_CAP_OP;
                        end else begin
                            bit_cnt_d = bit_cnt_q - 3'd1;
                        end
                    end
                end

                S_CAP_OP: begin
                    if (sobe_scl) begin
                        state_d = S_WAIT_STOP;
                        // Gera pulso de 1 ciclo em 'escrita' se endereço bater e operação == 0
                        if ((addr_ff == endereco_local) && (sda_sync1 == 1'b0)) begin
                            escrita_d = 1'b1;
                        end
                    end
                end

                S_WAIT_STOP: begin
                    state_d = S_WAIT_STOP;
                end

                default: begin
                    state_d   = S_IDLE;
                    bit_cnt_d = 3'd6;
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // 4. Atribuição das Portas de Saída
    // -------------------------------------------------------------------------
    assign endereco_recebido = addr_ff;
    assign operacao          = op_q;
    assign escrita           = escrita_q;
    // Nota: Caso o testbench espere 'escrita' contínua em nível alto até o Stop,
    // substitua a linha acima por:
    // assign escrita = (state_q == S_WAIT_STOP) && (addr_ff == endereco_local) && (op_q == 1'b0);
    assign stop              = stop_q;

endmodule