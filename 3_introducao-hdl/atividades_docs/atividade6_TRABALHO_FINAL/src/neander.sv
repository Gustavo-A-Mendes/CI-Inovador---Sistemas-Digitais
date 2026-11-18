`timescale 1ns/1ps

import neander_pkg::*;

module neander (
    input   logic           clk_i,
    input   logic           rst_n_i,
    output  logic           hlt_o,
    output  logic   [7:0]   ac_o,
    output  logic   [7:0]   pc_o,
    output  logic   [7:0]   rem_o,
    output  logic   [7:0]   rdm_o,
    output  logic   [7:0]   ri_o,
    output  logic   [7:0]   mem_out_o,
    output  logic           mem_wen_o,
    output  logic           mem_ren_o,
    output  logic   [7:0]   t_o,
    output  logic   [3:0]   inst_code_o,
    output  logic   [2:0]   op_code_o
);
    
    // Instanciando Interfaces:
    ctrl_dpath_if   ctrl_dpath_bus();
    ctrl_mem_if     ctrl_mem_bus();
    dpath_mem_if    dpath_mem_bus();

    // ======================================================================
    //                          INSTANCIANDO MÓDULOS
    // ======================================================================

    // Controle:
    neander_control ND_CTRL0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .ctrl_dpath_bus_i(ctrl_dpath_bus.master),   // Conecta o Controle no MASTER
        .ctrl_mem_bus_i(ctrl_mem_bus.master),       // Conecta o Controle no MASTER
        .t_o(t_o)
    );

    // Datapath:
    neander_datapath ND_DPATH0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .ctrl_dpath_bus_i(ctrl_dpath_bus.slave),    // Conecta o Controle no SLAVE
        .dpath_mem_bus_i(dpath_mem_bus.master),     // Conecta o Controle no MASTER
        .pc_o(pc_o),
        .ac_o(ac_o),
        .ri_o(ri_o)
    );

    // BRAM:
    neander_mem ND_MEM0(
    // mem_vivado ND_MEM0(
        .clk_i(clk_i),
        .ctrl_mem_bus_i(ctrl_mem_bus.slave),        // Conecta o Controle no SLAVE
        .dpath_mem_bus_i(dpath_mem_bus.slave)       // Conecta o Controle no SLAVE
    );

    assign hlt_o        = ctrl_dpath_bus.ctrl_sgn.hlt;
    assign op_code_o    = ula_op_t'(ctrl_dpath_bus.ctrl_sgn.op_code);
    assign inst_code_o  = instructions_t'(ctrl_dpath_bus.status_sgn.inst_code);
    assign rem_o        = dpath_mem_bus.dpath_data.rem_q;
    assign rdm_o        = dpath_mem_bus.dpath_data.rdm_q;
    assign mem_out_o    = dpath_mem_bus.mem_data.mem_q;
    assign mem_wen_o    = ctrl_mem_bus.ctrl_sgn.w_en;
    assign mem_ren_o    = ctrl_mem_bus.ctrl_sgn.r_en;
endmodule