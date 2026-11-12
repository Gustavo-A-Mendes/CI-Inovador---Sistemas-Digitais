module contador1 #(
    parameter N = 22
) (
        input   logic clk_i, 
        input   logic rst_n_i,
        input   logic start_i,
        output  logic timer_o
    );

    localparam [N-1:0] TIMER_MAX = 22'b1 << (N-1);

    logic [N-1:0] counter;

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i)       counter <= 21'd0;
        else if (start_i)   counter <= counter + 1'd1;
    end 

    assign timer_o = (counter == TIMER_MAX);
endmodule