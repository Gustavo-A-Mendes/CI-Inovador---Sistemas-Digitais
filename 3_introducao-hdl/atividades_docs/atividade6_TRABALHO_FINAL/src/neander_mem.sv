`timescale 1ns/1ps

import neander_pkg::*;

module neander_mem (
    input   logic           clk_i,
    
    ctrl_mem_if.slave       ctrl_mem_bus_i,     // (input control_sgn)
    dpath_mem_if.slave      dpath_mem_bus_i     // (input dpath_data, output mem_data)
);
    // ======================================================================
    //                        MACROS DE ROTEAMENTO
    // ======================================================================
    `define CTRL_IN    ctrl_mem_bus_i.ctrl_sgn
    `define DPATH_IN  dpath_mem_bus_i.dpath_data
    `define MEM_OUT    dpath_mem_bus_i.mem_data
    
    // ======================================================================
    //                    INICIALIZAÇÃO DOS FIOS INTERNOS
    // ======================================================================

    // FIOS MEMORIA:
    logic [7:0] addr_w, wdata_d;


    // FIOS INTERFACE DPATH-MEM: Entrada de Dados   (MEM <- Datapath):
    assign addr_w   = `DPATH_IN.rem_q;
    assign wdata_d  = `DPATH_IN.rdm_q;


    // ======================================================================
    //                          INSTANCIANDO MEMÓRIA
    // ======================================================================
    
    // Instancia a memória SRAM:
    logic [7:0] sram [0:255];

    // ======================================================================
    //                            DEFININDO LÓGICA
    // ======================================================================
    always_ff @ ( posedge clk_i ) begin
        if (`CTRL_IN.w_en)    sram[addr_w] <= wdata_d;
    end 

    assign `MEM_OUT.mem_q = (`CTRL_IN.r_en) ? sram[addr_w] : 8'h00;

    `undef CTRL_IN
    `undef DPATH_IN
    `undef MEM_OUT
endmodule