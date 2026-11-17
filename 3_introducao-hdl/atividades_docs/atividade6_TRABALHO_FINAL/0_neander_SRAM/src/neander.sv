`timescale 1ns/1ps

module neander (
    input   logic   clk_i,
    input   logic   rst_n_i,
    output  logic   hlt_o
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
        .ctrl_mem_bus_i(ctrl_mem_bus.master)        // Conecta o Controle no MASTER
    );

    // Datapath:
    neander_datapath ND_DPATH0(
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .ctrl_dpath_bus_i(ctrl_dpath_bus.slave),    // Conecta o Controle no SLAVE
        .dpath_mem_bus_i(dpath_mem_bus.master)      // Conecta o Controle no MASTER
    );

    // SRAM:
    neander_mem ND_MEM0(
//    mem_vivado ND_MEM0(
        .clk_i(clk_i),
        .ctrl_mem_bus_i(ctrl_mem_bus.slave),        // Conecta o Controle no SLAVE
        .dpath_mem_bus_i(dpath_mem_bus.slave)       // Conecta o Controle no SLAVE
    );

    assign hlt_o = ctrl_dpath_bus.ctrl_sgn.hlt;
endmodule