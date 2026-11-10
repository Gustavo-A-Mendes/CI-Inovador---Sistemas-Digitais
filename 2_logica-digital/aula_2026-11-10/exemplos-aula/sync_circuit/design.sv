module design (
    input   logic clk, reset,
    input   logic [4:0] valor_maximo,
    output  logic [4:0] Q,
    output  logic fim
    );

    always_ff @( posedge clk or posedge reset ) begin
        if (reset)                  Q <= 5'd0;
        else if (Q < valor_maximo)  Q <= Q + 1'd1;
        else                        Q <= 5'd0;
    end
endmodule