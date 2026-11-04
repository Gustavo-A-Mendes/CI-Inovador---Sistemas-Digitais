module bit_counter #(
    parameter WIDTH = 8  // Largura do registo A (ajuste conforme necessário)
) (
    input  wire [WIDTH-1:0] A,
    output reg  [$clog2(WIDTH+1)-1:0] B
);

    integer i;

    always @(*) begin
        B = 0;
        for (i = 0; i < WIDTH; i = i + 1) begin
            if (A[i] == 1'b1) begin
                B = B + 1;
            end
        end
    end

endmodule