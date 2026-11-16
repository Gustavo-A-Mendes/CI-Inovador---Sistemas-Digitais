module semaforo_pedestre (
    input   logic           clk,
    input   logic           reset,
    output  logic   [2:0]   rua1,
    output  logic   [2:0]   rua2
);
/*
    Q = 3'[verde, amarelo, vermelho]
*/
    localparam logic [1:0]  S0 = 'b00,
                            S1 = 'b01,
                            S2 = 'b10;

    logic [1:0] curr_state, next_state;
    logic [3:0] count;
    logic       clear_count;
    logic       sinal, next_sinal;

    always_ff @( posedge clk ) begin
        if (reset)
            sinal <= 1'b0;
        else
            sinal <= next_sinal;
    end

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
        next_sinal = sinal;
        clear_count = 1'b0;
        rua1 = 3'b000;
        rua2 = 3'b000;

        case(curr_state)
            S0: begin
                rua1 = 3'b100;
                rua2 = 3'b001;
                if (count == 4'd5) begin
                    clear_count = 1'b1;
                    next_state = S1;
                end 
            end

            S1: begin
                if (sinal == 1'b0) begin
                    rua1 = 3'b010;
                    rua2 = 3'b001;
                end 
                else begin
                    rua1 = 3'b001;
                    rua2 = 3'b010;
                end

                if (count == 4'd2) begin
                    clear_count = 1'b1;
                    
                    if (sinal == 1'b0) begin
                        next_state = S2;
                        next_sinal = 1'b1;
                    end
                    else begin
                        next_state = S0;
                        next_sinal = 1'b0;
                    end
                end 
            end

            S2: begin
                rua1 = 3'b001;
                rua2 = 3'b100;
                if (count == 4'd5) begin
                    clear_count = 1'b1;
                    next_state = S1;
                end 
            end
            default: begin
                next_state = S0;
            end
        endcase
    end
endmodule