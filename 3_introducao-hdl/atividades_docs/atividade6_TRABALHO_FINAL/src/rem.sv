module rem (
    input   logic           clk_i,
    input   logic           rst_n_i,
    input   logic   [7:0]   rem_d,
    input   logic           load_i,
    output  logic   [7:0]   rem_q,
);

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)       rem_q <= 8'h00;
        else if (load_i)    rem_q <= rem_d;    
    end
endmodule