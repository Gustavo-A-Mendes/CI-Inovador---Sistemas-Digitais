`timescale 1ns/1ps

module nz (
    input   logic           clk_i,
    input   logic           rst_n_i,
    input   logic           load_i,
    input   logic   [1:0]   nz_d,
    output  logic   [1:0]   nz_q
);

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)       nz_q <= 2'b00;
        else if (load_i)    nz_q <= nz_d;    
    end
endmodule