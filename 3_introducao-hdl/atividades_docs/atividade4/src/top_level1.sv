/*
    Detector de sequência (Double-Click)
*/
`include "../src/fsm1.sv"
`include "../src/contador1.sv"

module top_level1 (
    input   logic clk_i, rst_n_i,
    input   logic B_i,
    output  logic LED_o,
    output  logic [2:0] state_o
);
    logic rst_int_n_w, start_w; // Sinais de controle
    logic timer_w;              // Sinais de status

    // instancia da FSM:
    fsm1 fsm0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .B_i(B_i),
        .timer_i(timer_w),
        .LED_o(LED_o),
        .rst_int_n_o(rst_int_n_w), 
        .start_o(start_w),
        .state_o(state_o)
    );

    // instancia do contador:
    contador1 #(.N(1)) c0(
        .clk_i(clk_i),
        .rst_n_i(rst_int_n_w),
        .start_i(start_w),
        .timer_o(timer_w)
    );

endmodule