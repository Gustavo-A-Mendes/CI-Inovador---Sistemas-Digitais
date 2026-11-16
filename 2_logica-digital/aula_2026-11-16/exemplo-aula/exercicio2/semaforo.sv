module semaforo_pedestre (
    input   logic           clk,
    input   logic           reset,
    input   logic           botao_pedestre,
    output  logic   [4:0]   Q
);

    localparam logic [1:0]  S0 = 'b00,
                            S1 = 'b01,
                            S2 = 'b10;

    logic [1:0] curr_state, next_state;
    logic [3:0] count;
    logic       clear_count;

    always_ff @( posedge clk ) begin
        if (reset || clear_count)  
            count <= 4'b1;
        else        
            count <= count + 1'b1;
    end

    always_ff @( posedge clk ) begin
        if (reset)  curr_state <= S0;
        else        curr_state <= next_state;
    end

    always_comb begin
        next_state = curr_state;
        clear_count = 1'b0;
        Q = 5'b00_000;

        case(curr_state)
            S0: begin
                Q = 5'b01_100;
                if (botao_pedestre) begin
                    clear_count = 1'b1;
                    next_state = S1;
                end 
            end

            S1: begin
                Q = 5'b01_010;
                if (count == 4'd2) begin
                    clear_count = 1'b1;
                    next_state = S2;
                end 
            end

            S2: begin
                Q = 5'b10_001;
                if (count == 4'd4) begin
                    clear_count = 1'b1;
                    next_state = S0;
                end 
            end
            default: begin
                next_state = S0;
            end
        endcase
    end
endmodule