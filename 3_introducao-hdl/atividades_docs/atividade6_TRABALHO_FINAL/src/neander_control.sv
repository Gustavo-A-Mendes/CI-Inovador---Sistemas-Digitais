`timescale 1ns/1ps

import neander_pkg::*;

module neander_control (
    input   logic               clk_i,
    input   logic               rst_n_i,
    ctrl_dpath_if.master        ctrl_dpath_bus_i,   // (input status_sgn, output ctrl_sgn)
    ctrl_mem_if.master          ctrl_mem_bus_i,     // (output ctrl_sgn)

    // Saída de sinais internos dos registrador(es):
    output  logic       [7:0]   t_o
);

    // ======================================================================
    //                        MACROS DE ROTEAMENTO
    // ======================================================================
    `define STATUS_IN  ctrl_dpath_bus_i.status_sgn
    `define CTRL_OUT   ctrl_dpath_bus_i.ctrl_sgn
    `define MEM_OUT    ctrl_mem_bus_i.ctrl_sgn

    // ======================================================================
    //                    INICIALIZAÇÃO DOS FIOS INTERNOS
    // ======================================================================
    
    // FIOS CONTROL:
    logic [7:0] t_q;

    // ======================================================================
    //                          INSTANCIANDO MÓDULOS
    // ======================================================================

    // Gerador tempo:
    gerador_tempo GT0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .goto_t0_i(`CTRL_OUT.goto_t0),
        .hlt_i(`CTRL_OUT.hlt),
        .t_q(t_q)
    );

    decod_instruncao DEC0(
        .inst_code_i(`STATUS_IN.inst_code),
        .nz_i(`STATUS_IN.nz),
        .t_i(t_q),
        .dpath_ctrl_o(`CTRL_OUT),
        .mem_ctrl_o(`MEM_OUT)
    );

    assign t_o = t_q;

    `undef STATUS_IN
    `undef CTRL_OUT
    `undef MEM_OUT
endmodule