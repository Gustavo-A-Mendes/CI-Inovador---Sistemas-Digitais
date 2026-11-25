module cdma_align (
    input   logic           clk,    // Relógio do Sistema (Tclk = 100ns)
    input   logic           reset,  // Reset ativo alto
    input   logic           di,     // Sinal de entrada de dado - 1 bit a cada 8 ciclos (MSB first)
    input   logic   [7:0]   padrao, // ref de padrão buscado nos bits de entrada "di"
    
    output  logic           encontrado,
    output  logic   [9:0]   atraso
);

    logic [2:0] clk_count;
    logic sample_en, encontrado_d;
    logic [9:0] delay_count;
    logic [7:0] data_shift_reg;

    always_ff @( posedge clk ) begin

    end

    // pulso a cada 8 ciclos de relógio:
    always_ff @( posedge clk ) begin
        if (reset) begin
            sample_en    <= 1'b0;
            encontrado_d <= 1'b0;
        end
        else if (clk_count == 3'd7) begin
            sample_en   <= 1'b1;
            clk_count   <= 3'd0;
            if (data_shift_reg == padrao)
                encontrado_d <= 1'b1;
        end
        else begin
            sample_en    <= 1'b0;
            encontrado_d <= 1'b0;
            clk_count    <= clk_count + 3'd1;
        end
    end

    // recebimento dos dados + contador do atraso:
    always_ff @( posedge clk ) begin
        if (reset) begin
            data_shift_reg  <= 8'b0000_0000;
            delay_count     <= 10'd0;
        end
        else if (sample_en) begin
            data_shift_reg  <= {data_shift_reg[6:0], di};
            delay_count     <= delay_count + 10'd1;;
        end
    end

    always_ff @( posedge clk ) begin
        if (reset) begin
            encontrado  <= 1'b0;
        end
        else if (sample_en)begin
            encontrado  <= encontrado_d;
        end
        else begin
            encontrado  <= 1'b0;
        end 
        if (encontrado)
            atraso <= delay_count;
    end
endmodule
