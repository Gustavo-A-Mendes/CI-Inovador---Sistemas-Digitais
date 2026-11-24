module encoder_rotativo (
    input  logic clk,
    input  logic reset,
    input  logic a,
    input  logic b,
    output logic passo_a,
    output logic passo_b,
    output logic volta_a,
    output logic volta_b
);
    logic [1:0] ab;
    assign ab = {a, b};

    typedef enum logic [2:0] {
        ST_IDLE = 3'd0,
        ST_A_10 = 3'd1,
        ST_A_11 = 3'd2,
        ST_A_01 = 3'd3,
        ST_B_01 = 3'd4,
        ST_B_11 = 3'd5,
        ST_B_10 = 3'd6
    } state_t;

    state_t state, next_state;
    reg     step_a_pulse;
    logic   step_b_pulse;
    logic signed [5:0] net_steps; // +: passos em A | -: passos em B

    always@(*) begin
        next_state   = state;
        step_a_pulse = 1'b0;
        step_b_pulse = 1'b0;

        case (state)
            ST_IDLE: begin
                if (ab == 2'b10)      next_state = ST_A_10;
                else if (ab == 2'b01) next_state = ST_B_01;
            end

            // Sentido 1: A -> B (00 -> 10 -> 11 -> 01 -> 00)
            ST_A_10: begin
                if (ab == 2'b11)      next_state = ST_A_11;
                else if (ab != 2'b10) next_state = ST_IDLE;
            end

            ST_A_11: begin
                if (ab == 2'b01)      next_state = ST_A_01;
                else if (ab == 2'b10) next_state = ST_A_10;
                else if (ab == 2'b00) next_state = ST_IDLE;
            end

            ST_A_01: begin
                if (ab == 2'b00) begin
                    next_state   = ST_IDLE;
                    step_a_pulse = 1'b1;
                end else if (ab == 2'b11) begin
                    next_state   = ST_A_11;
                end else if (ab == 2'b10) begin
                    next_state   = ST_IDLE;
                end
            end

            // Sentido 2: B -> A (00 -> 01 -> 11 -> 10 -> 00)
            ST_B_01: begin
                if (ab == 2'b11)      next_state = ST_B_11;
                else if (ab != 2'b01) next_state = ST_IDLE;
            end

            ST_B_11: begin
                if (ab == 2'b10)      next_state = ST_B_10;
                else if (ab == 2'b01) next_state = ST_B_01;
                else if (ab == 2'b00) next_state = ST_IDLE;
            end

            ST_B_10: begin
                if (ab == 2'b00) begin
                    next_state   = ST_IDLE;
                    step_b_pulse = 1'b1;
                end else if (ab == 2'b11) begin
                    next_state   = ST_B_11;
                end else if (ab == 2'b01) begin
                    next_state   = ST_IDLE;
                end
            end

            default: next_state = ST_IDLE;
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= ST_IDLE;
            net_steps <= 6'sd0;
            passo_a   <= 1'b0;
            passo_b   <= 1'b0;
            volta_a   <= 1'b0;
            volta_b   <= 1'b0;
        end else begin
            state   <= next_state;
            passo_a <= step_a_pulse;
            passo_b <= step_b_pulse;
            volta_a <= 1'b0;
            volta_b <= 1'b0;

            if (step_a_pulse) begin
                if (net_steps == 6'sd15) begin
                    volta_a   <= 1'b1;
                    net_steps <= 6'sd0;
                end else begin
                    net_steps <= net_steps + 6'sd1;
                end
            end else if (step_b_pulse) begin
                if (net_steps == -6'sd15) begin
                    volta_b   <= 1'b1;
                    net_steps <= 6'sd0;
                end else begin
                    net_steps <= net_steps - 6'sd1;
                end
            end
        end
    end

endmodule