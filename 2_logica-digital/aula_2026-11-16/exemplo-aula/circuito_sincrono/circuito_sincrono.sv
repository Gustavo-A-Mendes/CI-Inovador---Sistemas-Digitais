module circuito_sincrono (
    input   logic           clk,
    input   logic           reset,
    input   logic           x,
    output  logic           match
);
    localparam VALOR_DESEJADO = 4'b0111;
    logic [3:0] dado_ff;

    always_ff @( posedge clk ) begin : blockName
        if (reset)      dado_ff <= 4'h0;
        else            dado_ff <= {dado_ff[2:0], x};
    end

    assign match = (dado_ff == VALOR_DESEJADO);
endmodule