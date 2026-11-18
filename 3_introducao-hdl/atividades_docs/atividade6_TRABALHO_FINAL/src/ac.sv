`timescale 1ns/1ps

module ac (
    input   logic           clk_i,
    input   logic           rst_n_i,
    input   logic           load_i,
    input   logic   [7:0]   ac_d,
    output  logic   [7:0]   ac_q
);

    always_ff @( posedge clk_i or negedge rst_n_i ) begin
        if (!rst_n_i)       ac_q <= 8'h00;
        else if (load_i)    ac_q <= ac_d;    
    end
endmodule