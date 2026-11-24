module cdma_align (
    input   logic           clk,    // Relógio do Sistema (Tclk = 100ns)
    input   logic           reset,  // Reset ativo alto
    input   logic           di,     // Sinal de entrada de dado - 1 bit a cada 8 ciclos (MSB first)
    input   logic   [7:0]   padrao, // ref de padrão buscado nos bits de entrada "di"
    
    output  logic           encontrado,
    output  logic   [9:0]   atraso
);

    logic [2:0] count_q, count_d;
    logic sample_en, encontrado_d;
    logic [9:0] delay_count, atraso_d, atraso_q;
    logic [7:0] data_shift_reg_d, data_shift_reg_q;

    typedef enum logic [3:0] { 
        REC_DADO        =   4'd0
    } state_t;

    state_t curr_state, next_state;

    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            curr_state          <= REC_DADO;
            data_shift_reg_q    <= 3'd0;
            count_q             <= 3'd0;
            delay_count         <= 10'd0;
            encontrado          <= 1'b0;
            atraso_q              <= 10'd0;
        end
        else begin
            curr_state          <= next_state;
            data_shift_reg_q    <= data_shift_reg_d;
            count_q             <= count_d;
            encontrado          <= encontrado_d;
            atraso_q              <= atraso_d;
        end
    end

    always_comb begin
        next_state = curr_state;
        data_shift_reg_d = data_shift_reg_q;
        sample_en = 1'b0;
        encontrado_d = 1'b0;
        atraso_d = atraso_q;

        case (curr_state)
            REC_DADO: begin
                count_d = count_q + 1;
                atraso_d = atraso_q + 1;
                
                if (count_q == 3'd4) begin
                    sample_en = 1'b1;
                end
                if (sample_en) begin
                    data_shift_reg_d = {data_shift_reg_q[6:0], di};
                    if (data_shift_reg_d == padrao) begin
                        encontrado_d = 1'b1;
                        atraso_d = 10'd0;
                    end
                end
                else if (count_q == 3'd7) begin
                    count_d = 3'd0;
                end
                if (encontrado) begin
                    atraso = atraso_q;
                end
            end
        endcase
    end
endmodule