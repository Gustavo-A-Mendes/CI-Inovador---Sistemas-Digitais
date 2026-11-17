module detector_pulso (
    input   logic   clk,
    input   logic   reset,
    input   logic   a,
    input   logic   b,
    output  logic   seq_a,
    output  logic   seq_b
);
    typedef enum logic [2:0] { 
        S0 = 3'b000,
        S1 = 3'b001,
        S2 = 3'b010,
        S3 = 3'b011,    // Sucesso A
        S4 = 3'b100,
        S5 = 3'b101,
        S6 = 3'b110     // Sucesso B
    } state_t;

    state_t curr_state, next_state;

    logic prev_a, prev_b;
    logic pulse_a, pulse_b;

    always_ff @( posedge clk ) begin
        if (reset) begin
            prev_a      <= 1'b0;
            prev_b      <= 1'b0;
        end
        else begin
            prev_a      <= a;
            prev_b      <= b;
        end
    end

    assign pulse_a = a & (~prev_a);
    assign pulse_b = b & (~prev_b);

    always_ff @( posedge clk ) begin
        if (reset) begin
            curr_state  <= S0;
        end
        else begin
            curr_state  <= next_state;
        end
    end

    always_comb begin
        next_state = curr_state;
        seq_a = 1'b0;
        seq_b = 1'b0;

        case(curr_state)
            S0: begin
                if (pulse_a)      next_state = S1;
                else if (pulse_b) next_state = S4;
            end

            S1: begin   // pulse_a = 1xx; pulse_b = xxx
                if (pulse_a)      next_state = S2;
                else if (pulse_b) next_state = S4;
            end

            S2: begin   // pulse_a = 11x; pulse_b = xxx
                if (pulse_a)      next_state = S3;
                else if (pulse_b) next_state = S4;
            end

            S3: begin   // pulse_a = 111; pulse_b = xxx
                seq_a = 1'b1;
                if (pulse_a)      next_state = S3;
                else if (pulse_b) next_state = S4;
            end

            S4: begin   // pulse_a = xxx; pulse_b = 1xx
                if (pulse_a)      next_state = S1;
                else if (pulse_b) next_state = S5;
            end

            S5: begin   // pulse_a = xxx; pulse_b = 11x
                if (pulse_a)      next_state = S1;
                else if (pulse_b) next_state = S6;
            end

            S6: begin   // pulse_a = xxx; pulse_b = 111
                seq_b = 1'b1;
                if (pulse_a)      next_state = S1;
                else if (pulse_b) next_state = S6;
            end
            default: next_state = S0;
        endcase

    end
endmodule